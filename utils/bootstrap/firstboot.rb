#!/usr/local/rbenv/shims/ruby
# Script for initial appliance setup:
# 1. genereates new apikey for admin user,
# 2. generates apikey for appliance user (appliance apikey is used by UI to access backend)
# 3. updates config files

# dont run if this is not the first boot.
unless File.file?('/srv/ontoportal/firstboot')
  puts 'firstboot script is skipped since this is not the first time boot'
  exit
end

system('sudo /usr/local/bin/opstatus') ||
  abort('Aborting! Some Ontoportal Services are not running')

Dir.chdir '/srv/ontoportal/bioportal_web_ui/current'
secret_key_base = `bundle exec rake secret`

require_relative '../apikey.rb'

CONFIG_FILE = '/srv/ontoportal/virtual_appliance/appliance_config/site_config.rb'.freeze
SECRETS_FILE = '/srv/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/secrets.yml'.freeze
MAINTENANCE_FILE = '/srv/ontoportal/bioportal_web_ui/current/public/system/maintenance.html'.freeze
UI_CONFIG_DIR = '/srv/ontoportal/bioportal_web_ui/current/config'.freeze

def aws_metadata_instance_id
  require 'net/http'
  require 'uri'
  uri = URI.parse('http://169.254.169.254/latest/meta-data/instance-id')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    case response
    # read AWS meta-data/instance-id
    when Net::HTTPSuccess
      # sanity check, instance id should start with i-
      if response.body.include? 'i-'
        response.body
      else
        false
      end
    else
      # metadata is off so falling back
      false
    end
  rescue Exception => e
    # metadata is probably not availalbe
    # puts "exception #{e.message}"
    false
  end
end

# Reset API keys
reset_apikey('admin')
reset_apikey('ontoportal_ui')
api_key = get_apikey('ontoportal_ui')


# AWS marketplace requires using randomized passwords for administrative access
# so we set instance_id as OntoPortal web Admin initial password
# https://docs.aws.amazon.com/marketplace/latest/userguide/product-and-ami-policies.html

instance_id = aws_metadata_instance_id

if instance_id
  cloud_provider = 'AWS'
  admin_apikey = get_apikey('admin')

  uri = URI.parse("http://localhost:8080/users/admin?apikey=#{admin_apikey}")
  request = Net::HTTP::Patch.new(uri)
  request.body = "password=#{instance_id}"

  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  puts response.code
  puts response.body
  puts "Running on AWS; admin password is set to #{instance_id}"
end

# update config files
# overwrite appliance apikey
site_config = File.read(CONFIG_FILE)
new_content = site_config.gsub(/^\$API_KEY =.*$/, "\$API_KEY = \"#{api_key}\"")
new_content = new_content.gsub(/^\$CLOUD_PROVIDER =.*$/, "\$CLOUD_PROVIDER = \'#{cloud_provider}\'")
File.open(CONFIG_FILE, 'w') { |file| file.puts new_content }
FileUtils.cp CONFIG_FILE, UI_CONFIG_DIR
# puts "UI API KEY #{api_key}"
# reset secret_key_base
secrets_yml = File.read(SECRETS_FILE)
new_content = secrets_yml.gsub(/^  secret_key_base: .*$/, "  secret_key_base: #{secret_key_base}")
File.open(SECRETS_FILE, 'w') { |file| file.puts new_content }
FileUtils.cp SECRETS_FILE, UI_CONFIG_DIR

FileUtils.chown 'ontoportal', 'ontoportal', UI_CONFIG_DIR
# system "cat /srv/rails/bioportal_web_ui/current/config/site_config.rb"
File.delete(MAINTENANCE_FILE) if File.exist?(MAINTENANCE_FILE)
puts 'initial OntoPortal config is complete,'
# restart ontoportal stack
system('sudo /usr/local/bin/oprestart')
