#!/usr/local/rbenv/shims/ruby
# Script for initial appliance setup:
# 1. genereates new apikey for admin user,
# 2. generates apikey for appliance user (appliance apikey is used by UI to access backend)
# 3. updates config files



# dont run if this is not the first boot.
unless File.file?('/srv/ncbo/firstboot')
  abort ('doesnt look like this is the first time boot; aborting!')
end

Dir.chdir "/srv/rails/bioportal_web_ui/current"
secret_key_base = `bundle exec rake secret`

require_relative '../apikey.rb'

CONFIG_FILE = '/srv/ncbo/virtual_appliance/appliance_config/site_config.rb'
SECRETS_FILE = '/srv/ncbo/virtual_appliance/appliance_config/bioportal_web_ui/config/secrets.yml'

# Reset API keys
reset_apikey('admin')
reset_apikey('ontoportal_ui')
api_key = get_apikey('ontoportal_ui')

#set Admin password to the AWS AMI ID
if `virt-what | tail -1` == 'aws'
  require 'net/http'
  require 'uri'
  admin_apikey = get_apikey('admin')
  #get instance ID
  uri = URI.parse('http://169.254.169.254/latest/meta-data/instance-id')
  res = Net::HTTP.get_response(uri)
  instance_id = res.body

  uri = URI.parse("http://localhost:8080/users/admin?apikey=#{admin_apikey}")
  request = Net::HTTP::Patch.new(uri)
  request.body = "password=#{instance_id}"

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

   puts response.code
   puts response.body
   puts ("Running on AWS; admin password is set to #{instance_id}")
end


# update config files
# overwrite appliance apikey
site_config = File.read(CONFIG_FILE)
new_content = site_config.gsub(/^\$API_KEY =.*$/, "\$API_KEY = \"#{api_key}\"")
File.open(CONFIG_FILE, 'w') { |file| file.puts new_content }
FileUtils.cp "#{CONFIG_FILE}", '/srv/rails/bioportal_web_ui/current/config'
puts "UI API KEY #{api_key}"
# reset secret_key_base
secrets_yml = File.read(SECRETS_FILE)
new_content = secrets_yml.gsub(/^  secret_key_base: .*$/, "  secret_key_base: #{secret_key_base}")
File.open(SECRETS_FILE, 'w') { |file| file.puts new_content }
FileUtils.cp "#{SECRETS_FILE}", '/srv/rails/bioportal_web_ui/current/config'

FileUtils.chown 'ontoportal', 'ontoportal', '/srv/rails/bioportal_web_ui/current/config'
# system "cat /srv/rails/bioportal_web_ui/current/config/site_config.rb"

puts ("initial ontoportal config is complete,")
# restart ontoportal stack
system "sudo /usr/local/bin/oprestart"
