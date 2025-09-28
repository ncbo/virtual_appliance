#!/usr/local/rbenv/shims/ruby
# frozen_string_literal: true

# -----------------------------------------------------------------------------
# Part of the OntoPortal Virtual Appliance Project
# https://ontoportal.org
#
# Author: Alex Skrenchuk (@alexskr)
# Copyright (c) 2025 Stanford University and the OntoPortal Alliance
# SPDX-License-Identifier: Apache-2.0
#
# Description:
#   This script runs once on the first boot of the appliance. It resets API keys,
#   generates a self-signed TLS certificate, configures initial user credentials,
#   and prepares the OntoPortal environment for first use.
# -----------------------------------------------------------------------------

require 'fileutils'
require 'net/http'
require 'uri'
require 'openssl'
require 'logger'
require 'etc'
require 'open3'
require '/usr/local/ontoportal/bin/infra_discovery'

# Constants
ADMIN = 'op-admin'
FIRSTBOOT_MARKER = '/opt/ontoportal/config/firstboot'
CONFIG_FILE = '/opt/ontoportal/config/site_config.rb'
SECRETS_FILE = '/opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/secrets.yml'
MAINTENANCE_FILE = '/opt/ontoportal/bioportal_web_ui/current/public/system/maintenance.html'
UI_CONFIG_DIR = '/opt/ontoportal/bioportal_web_ui/current/config'
GEMFILE_PATH = '/opt/ontoportal/bioportal_web_ui/current/Gemfile'
APIKEY_SCRIPT = '/opt/ontoportal/virtual_appliance/utils/apikey.rb'
GEN_TLS_SCRIPT = '/usr/local/ontoportal/bin/gen_tlscert'

# Logger setup
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO
$logger.formatter = proc do |severity, datetime, _progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} - #{msg}\n"
end

# Main script
begin
  # Require 'ontoportal' user
  if ENV['USER'] != ADMIN && Process.uid != Etc.getpwnam(ADMIN).uid
    $logger.fatal "Must run as #{ADMIN} user. Current: #{ENV['USER']}"
    exit 1
  end

  unless File.file?(FIRSTBOOT_MARKER)
    $logger.info 'Not first boot. Skipping script.'
    exit
  end

  $logger.info 'Starting OntoPortal first boot setup...'

  # Wait for services to come online
  n = 0
  until system('sudo /usr/local/bin/opctl status')
    $logger.info 'Waiting for OntoPortal services...'
    sleep 15
    n += 1
    raise 'Services failed to start.' if n > 5
  end

  # Generate API keys
  admin_apikey = `ruby #{APIKEY_SCRIPT} reset admin`.lines.last&.strip
  ui_apikey = `ruby #{APIKEY_SCRIPT} reset ontoportal_ui`.lines.last&.strip
  $logger.info "Admin API key: #{admin_apikey}"
  $logger.info "UI API key: #{ui_apikey}"

  # Determine cloud provider and instance ID
  cloud_provider = InfraDiscovery.cloud_provider
  instance_id = cloud_provider == 'AWS' ? InfraDiscovery.aws_instance_id : nil

  if cloud_provider == 'AWS'
    $logger.info "AWS instance detected. ID: #{instance_id}"

    if instance_id
      uri = URI("https://localhost:8443/users/admin?apikey=#{admin_apikey}")
      request = Net::HTTP::Patch.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = "password=#{instance_id}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      begin
        response = http.start { |h| h.request(request) }
        if response.code.to_i.between?(200, 299)
          $logger.info "Admin password set to instance ID"
        else
          $logger.error "Failed to set admin password: #{response.code} #{response.body}"
        end
      rescue StandardError => e
        $logger.error "Exception setting admin password: #{e.message}"
      end
    end
  end

  # Update site config
  if File.exist?(CONFIG_FILE)
    site_config = File.read(CONFIG_FILE)
    updated_config = site_config.gsub(/^\$API_KEY =.*$/, "$API_KEY = \"#{ui_apikey}\"")
                                .gsub(/^\$CLOUD_PROVIDER =.*$/, "$CLOUD_PROVIDER = '#{cloud_provider}'")
    File.write(CONFIG_FILE, updated_config)
    FileUtils.cp CONFIG_FILE, UI_CONFIG_DIR
    FileUtils.chown ADMIN, ADMIN, UI_CONFIG_DIR
    $logger.info 'Updated appliance configuration.'
  else
    $logger.error "Site config not found: #{CONFIG_FILE}"
  end

  # Reset UI encrypted credentials
  Dir.chdir('/opt/ontoportal/bioportal_web_ui/current')
  ENV['BUNDLE_GEMFILE'] = GEMFILE_PATH
  system('/opt/ontoportal/virtual_appliance/utils/bootstrap/reset_ui_encrypted_credentials.sh')

  # Generate TLS certificate (hostname auto-detected internally)
  tls_cmd = "sudo #{GEN_TLS_SCRIPT} --add-to-trust"
  $logger.info "Generating TLS certificate: #{tls_cmd}"
  system(tls_cmd)

  # Restart services
  $logger.info 'Restarting OntoPortal stack...'
  system('sudo /usr/local/bin/opctl restart')
  system('sudo /usr/local/bin/opctl status')

  # Remove maintenance page if present
  File.delete(MAINTENANCE_FILE) if File.exist?(MAINTENANCE_FILE)

  $logger.info 'OntoPortal initial bootstrap is complete.'

rescue => e
  $logger.fatal "Unhandled exception: #{e.message}"
  $logger.fatal e.backtrace.join("\n")
  exit 1
end

