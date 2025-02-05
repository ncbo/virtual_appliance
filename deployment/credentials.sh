#!/bin/bash
# sets up deployment environment for the appliance
#
# Script pulls various ncbo bioportal repos that it needs for running capistrano deployment
# its a bit of an overkill but is consistent with the way that bioportal stack is deployed in production 
# script locks repos to specific tags which should be compatible with this particular version of appliance

generate_secret_key_base() {
  #echo $(bundle exec rails secret)
  echo $(bin/rails secret)
}

source "$(dirname "$0")/config.sh"
echo '====> Setting up deployment environment'
bundle config --global set deployment 'true'
bundle config --global set path $BUNDLE_PATH
CONFIG_DIR=$VIRTUAL_APPLIANCE_REPO/appliance_config
cat ~/.bundle/config
# copy default version controlled config files to local config files
[ -e ${CONFIG_DIR}/site_config.rb ] || cp ${CONFIG_DIR}/site_config.rb.default ${CONFIG_DIR}/site_config.rb
[ -e ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb ] || cp ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb.default ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb
[ -e ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb ] || cp ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb.default ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb
[ -e ${CONFIG_DIR}/ncbo_cron/config/config.rb ] || cp ${CONFIG_DIR}/ncbo_cron/config/config.rb.default ${CONFIG_DIR}/ncbo_cron/config/config.rb

pushd bioportal_web_ui
pwd
echo "!!!!! need to set up creds in ${VIRTUAL_APPLIANCE_REPO} repo"
# set up encrypted credentials, rails v5.2 is required"
if [ ! -f ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/credentials/appliance.yml.enc ]; then
  echo "====> setting rails credentials"
  SECRET_KEY_BASE=$(generate_secret_key_base)
  # Generate a new master key
  EDITOR="true" bundle exec rails credentials:edit --environment appliance
  # Generate a secret_key_base and store it in the encdrypted credentials file
  EDITOR='echo "secret_key_base: $SECRET_KEY_BASE" >> ' bundle exec rails credentials:edit --environment appliance
  EDITOR='echo "test: 123" >> ' bundle exec rails credentials:edit --environment appliance
  if [ $? -ne 0 ]; then
    echo "==>  Unable to generate secret !!!"
    exit
  fi
  cp config/credentials/appliance.* ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/credentials/
fi
popd

