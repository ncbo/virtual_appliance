#!/usr/bin/env ruby
#bootstraps ontoportal tripple store KB.
#

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
require_relative 'useradmin.rb'
# Get cron configuration.
require "#{NCBO_CRON_PATH}/lib/ncbo_cron"
require "#{NCBO_CRON_PATH}/config/config.rb";




createuser('admin22', 'admin@nodomain.org', 'OPchangemeNOW')
adminify('admin22')
createuser('ontoportal_ui1', 'ontoportal_ui@nodomain.org')

