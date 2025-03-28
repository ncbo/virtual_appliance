#!/usr/bin/env ruby
# manipulates apikey for a user

NCBO_CRON_PATH = '/opt/ontoportal/ncbo_cron'

Dir.chdir NCBO_CRON_PATH

Signal.trap("INT") { exit! }

require 'bundler/setup'
require 'securerandom'

require "#{NCBO_CRON_PATH}/lib/ncbo_cron"
require "#{NCBO_CRON_PATH}/config/config.rb"

def reset_apikey(username)
  user = LinkedData::Models::User.find(username).first
  user.bring_remaining
  user.valid?
  user.apikey = SecureRandom.uuid
  user.save
  user.apikey
end

def get_apikey(username)
  user = LinkedData::Models::User.find(username).first
  user.bring_remaining
  user.valid?
  user.apikey
end

# === CLI Support ===
if __FILE__ == $0
  args = ARGV.dup
  verbose = args.delete('--verbose')
  command, username = args

  unless %w[reset get].include?(command) && username
    warn "Usage: ruby #{__FILE__} [--verbose] [reset|get] USERNAME"
    exit 1
  end

  case command
  when 'reset'
    apikey = reset_apikey(username)
    puts "apikey has been reset for #{username} user" if verbose
    puts apikey
  when 'get'
    apikey = get_apikey(username)
    puts "retrieved apikey for #{username}:" if verbose
    puts apikey
  end
end

