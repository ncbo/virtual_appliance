#!/bin/bash
set -euo pipefail
# script for resetting rails encrypted credentials for appliance environment
# FIXME: this needs to be re-written as a rake task*
  CONF_CRED_DIR="/opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/credentials"
  echo "====> resetting rails encrypted credentials"
  export BUNDLE_PATH='/opt/ontoportal/.bundle'
  export RAILS_ENV=appliance
  export DISABLE_BOOTSNAP=true
  SECRET=$(bin/rails secret)
  if [ $? -ne 0 ]; then
    echo "==> ❌ Unable to generate secret !!!"
    exit 1
  fi

  for i in \
    "/opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/credentials/${RAILS_ENV}.key" \
    "/opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/credentials/${RAILS_ENV}.yml.enc" \
    "/opt/ontoportal/bioportal_web_ui/config/credentials/${RAILS_ENV}.key" \
    "/opt/ontoportal/bioportal_web_ui/config/credentials/${RAILS_ENV}.yml.enc" \
    "config/master.key" \
    "config/master.yml.enc" \
    "config/credentials/${RAILS_ENV}.key" \
    "config/credentials/${RAILS_ENV}.yml.enc"
  do
  if [[ -f "$i" ]]; then
    rm "$i"
    echo "removed $i"
  fi
  done


  # with bioportal v7.5.0 / rails 7.2 upgrade bin/rails command fails without bioportal_config_env file in place 
  # typically that file is 
  [[ -f config/bioportal_config_${RAILS_ENV}.rb ]] || touch config/bioportal_config_${RAILS_ENV}.rb

  # Generate a secret_key_base and store it in credentials
  # EDITOR='echo "secret_key_base: $(bundle exec rake secret)" > ' bundle exec rails credentials:edit --environment appliance
  # generating credentials file and programmatically adding keys to it doesn't work in rails 7.0 when used with --environemnt
  # this issue is addressed in rails 7.1
  # As a temporary workaround we generate credentials for production env and copy files into appliance env.

  #EDITOR='echo "secret_key_base: $(bin/rails secret)" > ' bin/rails credentials:edit --environment appliance
  EDITOR='echo "secret_key_base: $(bin/rails secret)" > ' bin/rails credentials:edit
  if [ $? -ne 0 ] || [ ! -f config/credentials.yml.enc ] ; then
    echo "==> ❌ Unable to generate encrypted cred file !!!"
    exit
  fi

#  mv config/master.key config/credentials/${RAILS_ENV}.key
#  mv config/credentials.yml.enc config/credentials/${RAILS_ENV}.yml.enc

  # copy encrypted creds to config dir
  #cp config/credentials/${RAILS_ENV}.* ${CONF_CRED_DIR}/ || exit 1
  mv config/master.key ${CONF_CRED_DIR}/${RAILS_ENV}.key
  mv config/credentials.yml.enc ${CONF_CRED_DIR}/${RAILS_ENV}.yml.enc
  chown op-admin:op-ui ${CONF_CRED_DIR}/${RAILS_ENV}.*
  chmod 0640 ${CONF_CRED_DIR}/${RAILS_ENV}.* 

  # copy encrypted creds to deployed bioportal ui dir
  if [[ -d /opt/ontoportal/bioportal_web_ui/current/config ]]; then
    # rsync is used in order to keep perms/ownership
    cp --preserve=mode,ownership ${CONF_CRED_DIR}/appliance.* /opt/ontoportal/bioportal_web_ui/current/config/credentials
  fi

echo "✅ done resetting rails encrypted credentials"
