#!/usr/bin/env ruby
# Script for initial appliance setup:
# 1. genereates new apikey for admin user,
# 2. generates apikey for appliance user (appliance apikey is used by UI to access backend)
# 3. updates config files



# dont run if this is not the first boot.
unless File.file?('/root/firstboot')
  abort ('doesnt look like this is the first time boot; aborting!')
end

require_relative '../apikey.rb' 

CONFIG_FILE = '/srv/ncbo/virtual_appliance/appliance_config/site_config.rb'

reset_apikey('admin')
reset_apikey('ontoportal_ui')
api_key = get_apikey('ontoportal_ui')

# update config files
# overwrite appliance apikey
text = File.read(CONFIG_FILE)
new_content = text.gsub(/^\$API_KEY =.*$/, "\$API_KEY = \"#{api_key}\"")
File.open(CONFIG_FILE, 'w') { |file| file.puts new_content }

FileUtils.cp "#{CONFIG_FILE}", '/srv/rails/bioportal_web_ui/current/config'
FileUtils.chown 'ontoportal', 'ontoportal', '/srv/rails/bioportal_web_ui/current/config'
puts ("initial ontoportal config is complete")
# restart ontoportal stack
system "/usr/local/bin/oprestart"
