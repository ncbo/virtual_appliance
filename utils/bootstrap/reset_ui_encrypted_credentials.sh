#!/bin/bash
# script for resetting rails encrypted credentials for appliance environment
# FIXME: this needs to be re-written as a rake task
  echo "====> resetting rails encrypted credentials"
  export BUNDLE_PATH='/opt/ontoportal/.bundle'
  SECRET=$(bin/rails secret)
  if [ $? -ne 0 ]; then
    echo "==> ❌ Unable to generate secret !!!"
    exit 1
  fi

  # Generate a secret_key_base and store it in credentials
  # EDITOR='echo "secret_key_base: $(bundle exec rake secret)" > ' bundle exec rails credentials:edit --environment appliance
  # generating credentials file and programmatically adding keys to it doesn't work in rails 7.0 when used with --environemnt
  # this issue is addressed in rails 7.1
  # As a temporary workaround we generate credentials for production env and copy files into appliance env.

  #EDITOR='echo "secret_key_base: $(bin/rails secret)" > ' bin/rails credentials:edit --environment appliance
  EDITOR='echo "secret_key_base: $(bin/rails secret)" > ' bin/rails credentials:edit
  if [ $? -ne 0 ] || [ ! -f config/credentials.yml.enc ] ; then
    echo "==> ❌ Unable to generate secret !!!"
    exit
  fi

  mv config/master.key config/credentials/appliance.key
  mv config/credentials.yml.enc config/credentials/appliance.yml.enc

  cp config/credentials/appliance.* /opt/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/credentials/ || exit 1
popd
echo "✅ done resetting rails encrypted credentials"
