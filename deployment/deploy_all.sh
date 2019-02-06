#!/usr/bin/env bash
#deploy the application stack
#this script needs to be run as bioportal user

./setupenv.sh
./deploy_solr.sh
./deploy_api.sh
./deploy_ui.sh
./deploy_ncbo_cron.sh
./deploy_biomixer.sh

sudo /usr/local/bin/oprestart
