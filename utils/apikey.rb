#!/usr/bin/env ruby
# manipulates apikey for a user

NCBO_CRON_PATH='/srv/ontoportal/ncbo_cron'

# Script uses ncbo_cron for changing apikey becase its easier then
# working with the API since it requires deleting/re-creating user.
# NOTE: ontoportal stack might need to be restarted after this is run.

Dir.chdir NCBO_CRON_PATH

# Exit cleanly from an early interrupt
Signal.trap("INT") { exit! }

# Setup the bundled gems in our environment
require 'bundler/setup'
require 'securerandom'

# Get cron configuration.
require "#{NCBO_CRON_PATH}/lib/ncbo_cron"
require "#{NCBO_CRON_PATH}/config/config.rb";

def reset_apikey(username)
  user = LinkedData::Models::User.find(username).first
  user.bring_remaining
  user.valid?
  user.apikey =  SecureRandom.uuid
  user.save
  puts "apikey has been reset for #{username} user"
end

def get_apikey(username)
  user = LinkedData::Models::User.find(username).first
  user.bring_remaining
  user.valid?
  return user.apikey
end

