#!/usr/local/rbenv/shims/ruby
# Script for initial appliance setup:
# 1. generates new apikey for admin user,
# 2. generates apikey for appliance user (used by UI to access backend),
# 3. updates config files
# Skips if not first boot.

require 'fileutils'
require 'net/http'
require 'uri'
require 'openssl'

FIRSTBOOT_MARKER = '/opt/ontoportal/firstboot'.freeze
CONFIG_FILE = '/opt/ontoportal/virtual_appliance/appliance_config/site_config.rb'.freeze
SECRETS_FILE = '/opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/secrets.yml'.freeze
MAINTENANCE_FILE = '/opt/ontoportal/bioportal_web_ui/current/public/system/maintenance.html'.freeze
UI_CONFIG_DIR = '/opt/ontoportal/bioportal_web_ui/current/config'.freeze
GEMFILE_PATH = '/opt/ontoportal/bioportal_web_ui/current/Gemfile'.freeze
APIKEY_SCRIPT = '/opt/ontoportal/virtual_appliance/utils/apikey.rb'.freeze

def log(msg)
  puts "[firstboot] #{msg}"
end

unless File.file?(FIRSTBOOT_MARKER)
  log 'Script skipped: not the first boot.'
  exit
end

log 'Starting firstboot script...'

# Wait for OntoPortal services to be up
n = 0
until system('sudo /usr/local/bin/opstatus')
  log 'Some services are not running. Waiting 15 seconds...'
  sleep 15
  n += 1
  abort('[firstboot] Aborting! OntoPortal services failed to start.') if n > 5
end

def aws_metadata_instance_id
  uri = URI.parse('http://169.254.169.254/latest/meta-data/instance-id')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    return response.body if response.is_a?(Net::HTTPSuccess) && response.body.include?('i-')
  rescue StandardError
    # AWS metadata service likely unavailable
  end

  false
end

# Reset API keys
admin_apikey = `ruby #{APIKEY_SCRIPT} reset admin`.lines.last.strip
ui_apikey = `ruby #{APIKEY_SCRIPT} reset ontoportal_ui`.lines.last.strip

puts admin_apikey
puts ui_apikey
# Determine cloud environment
cloud_provider = 'LOCAL'
instance_id = aws_metadata_instance_id

if instance_id
  cloud_provider = 'AWS'

  uri = URI.parse("https://localhost:8443/users/admin?apikey=#{admin_apikey}")
  request = Net::HTTP::Patch.new(uri)
  request['Content-Type'] = 'application/x-www-form-urlencoded'
  request.body = "password=#{instance_id}"

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Accept self-signed certs

  begin
    response = http.start { |h| h.request(request) }

    if response.code.to_i.between?(200, 299)
      log "Admin password set to instance ID: #{instance_id}"
    else
      log "Failed to set admin password: #{response.code} #{response.body}"
    end
  rescue StandardError => e
    log "Error setting admin password: #{e.message}"
  end
end

# Update config files with new API key and cloud provider
site_config = File.read(CONFIG_FILE)
new_content = site_config.gsub(/^\$API_KEY =.*$/, "$API_KEY = \"#{ui_apikey}\"")
                         .gsub(/^\$CLOUD_PROVIDER =.*$/, "$CLOUD_PROVIDER = '#{cloud_provider}'")
File.write(CONFIG_FILE, new_content)

FileUtils.cp CONFIG_FILE, UI_CONFIG_DIR
FileUtils.chown 'ontoportal', 'ontoportal', UI_CONFIG_DIR

# Reset encrypted credentials
Dir.chdir('/opt/ontoportal/bioportal_web_ui/current')
ENV['BUNDLE_GEMFILE'] = GEMFILE_PATH
system('/opt/ontoportal/virtual_appliance/utils/bootstrap/reset_ui_encrypted_credentials.sh')

# Update TLS certificates and truststore
system('sudo /opt/ontoportal/virtual_appliance/utils/bootstrap/gen_tlscert.sh updatetruststore')

# Restart OntoPortal stack
log 'Restarting OntoPortal stack...'
system('sudo /usr/local/bin/oprestart')
system('sudo /usr/local/bin/opstatus')

# Remove maintenance page if it exists
File.delete(MAINTENANCE_FILE) if File.exist?(MAINTENANCE_FILE)

log 'Initial OntoPortal bootstrap is complete.'
