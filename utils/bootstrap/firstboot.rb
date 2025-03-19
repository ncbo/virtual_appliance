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

puts 'starting firstboot script'

n = 0
until system('sudo /usr/local/bin/opstatus')
  # some services might be slow to start on VMs with low resources
  puts 'some services are not running. waiting for 15 seconds for the services to start'
  sleep 15
  n += 1
  abort('Aborting! Some Ontoportal Services failed to start. Unable to continue') if n > 5
end
require_relative '../apikey'

CONFIG_FILE = '/opt/ontoportal/virtual_appliance/appliance_config/site_config.rb'.freeze
SECRETS_FILE = '/opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/secrets.yml'.freeze
MAINTENANCE_FILE = '/opt/ontoportal/bioportal_web_ui/current/public/system/maintenance.html'.freeze
UI_CONFIG_DIR = '/opt/ontoportal/bioportal_web_ui/current/config'.freeze

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
  rescue StandardError => e
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
FileUtils.chown 'ontoportal', 'ontoportal', UI_CONFIG_DIR

# reset ontoportal instance id
# system('redis-cli del ontoportal.instance.id')

Dir.chdir '/opt/ontoportal/bioportal_web_ui/current'
# force loading bootsnap gem
ENV['BUNDLE_GEMFILE'] = "/opt/ontoportal/bioportal_web_ui/current/Gemfile"
system('/opt/ontoportal/virtual_appliance/utils/bootstrap/reset_ui_encrypted_credentials.sh')
system('sudo /opt/ontoportal/virtual_appliance/utils/bootstrap/gen_tlscert.sh')
# restart ontoportal stack
puts "Restarting OntoPortal stack"
system('sudo /usr/local/bin/oprestart')
system('sudo /usr/local/bin/opstatus')

File.delete(MAINTENANCE_FILE) if File.exist?(MAINTENANCE_FILE)

puts 'initial OntoPortal bootstrap is complete,'
