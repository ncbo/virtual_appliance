#!/bin/bash
# DO NOT RUN

if [ "$1" != "nukeit" ]; then
  echo "not gonna do it just like that"
  exit 1
fi

APP=/opt/ontoportal
VA=${APP}/virtual_appliance
sudo opctl stop

# remove generated config
/bin/rm -Rf ${VA}/appliance_config/ontologies_linked_data
/bin/rm ${VA}/appliance_config/bioportal_web_ui/config/credentials/appliance.key
/bin/rm ${VA}/appliance_config/bioportal_web_ui/config/credentials/appliance.yml.enc
/bin/rm ${VA}/appliance_config/bioportal_web_ui/config/site_config.rb
/bin/rm ${VA}/appliance_config/bioportal_web_ui/config/bioportal_config_appliance.rb
/bin/rm ${VA}/appliance_config/ncbo_cron/config/config.rb
/bin/rm ${VA}/appliance_config/ontologies_api/config/environments/appliance.rb
/bin/rm ${VA}/appliance_config/site_config.rb
/bin/rm ${VA}/config/site_config.rb

# remove deployed app
/bin/rm -Rf /opt/ontoportal/bioportal_web_ui/releases/*
/bin/rm -Rf /opt/ontoportal/ontologies_api/releases/*
/bin/rm -Rf /opt/ontoportal/ncbo_cron

# remove directories used for capistrano deployment
/bin/rm -Rf ${VA}/deployment/bioportal_web_ui
/bin/rm -Rf ${VA}/deployment/ontologies_api
