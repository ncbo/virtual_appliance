#!/usr/bin/env ruby
# Reset apikey for user

NCBO_CRON_PATH='/srv/ncbo/ncbo_cron'
USERNAME = 'admin'

# we are relying on ncbo_cron project for changing apikey becase its easier then
# working with the API since it requires deleting/re-creating user.

Dir.chdir NCBO_CRON_PATH
puts Dir.pwd

# Exit cleanly from an early interrupt
Signal.trap("INT") { exit! }

# Setup the bundled gems in our environment
require 'bundler/setup'
require 'securerandom'

# Get cron configuration.
require "#{NCBO_CRON_PATH}/lib/ncbo_cron"
require "#{NCBO_CRON_PATH}/config/config.rb";

user = LinkedData::Models::User.find(USERNAME).first
user.bring_remaining
user.valid?
user.apikey =  SecureRandom.uuid
user.save
puts "apikey has been reset for admin user"
