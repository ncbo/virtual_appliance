#!/usr/bin/env bash
# OntoPortal Appliance application deployment script
# this script needs to be run as ontoportal user
if [ "$USER" != 'ontoportal' ]; then
  echo "you need to run this script as ontoportal user"
  exit 1
fi

./setup_deploy_env.sh
./deploy_solr.sh
./deploy_api.sh
./deploy_ui.sh
./deploy_ncbo_cron.sh
./deploy_biomixer.sh
./deploy_annotatorproxy.sh

sudo /usr/local/bin/oprestart
