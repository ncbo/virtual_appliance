#!/usr/bin/env ruby
# manipulates apikey for a user

NCBO_CRON_PATH='/srv/ncbo/ncbo_cron'

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

def adminify(username)
  user = LinkedData::Models::User.find(username).first
  user.bring_remaining
  user.valid?
  # Get an instance of the administrator role
  role = LinkedData::Models::Users::Role.find("ADMINISTRATOR").first
  role.bring_remaining

  # Sanity check that you have a valid role
  role.valid?
  # Add the administrative role to the user's list of roles
  user_roles = user.role
  user_roles = user_roles.dup
  user_roles << role
  user.role = user_roles

  # Sanity check to make sure role was added properly
  user.valid?

  puts user.role 
  # Don't forget to save...
  user.save

end

def resetpassword(username)
  newpassword = SecureRandom.base64
  user = LinkedData::Models::User.find(username).first
  user.bring_remaining
  user.valid?
  user.password = newpassword
  user.valid?
  puts "password for user #{username} is reset to #{newpassword}"
 # user.save
end

input_array = ARGV
username = input_array[0]
if input_array.length == 0
  puts "require username"
  exit 1
end
puts username

#resetpassword(username)
#adminify(username)
