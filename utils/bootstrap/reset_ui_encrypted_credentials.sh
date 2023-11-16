#!/bin/bash
# script for resetting ROR encrypted credentials for appliance environment
# FIXME: this needs to be re-written as a rake task

pushd /srv/ontoportal/bioportal_web_ui/current || exit 1
  echo "====> resetting rails encrypted credentials"
  SECRET=$(/usr/local/rbenv/shims/bundle exec rake secret)
  if [ $? -ne 0 ]; then
    echo "==> Unable to generate secret !!!"
    exit 1
  fi

  EDITOR='echo "secret_key_base: $(bundle exec rake secret)" > ' bundle exec rails credentials:edit --environment appliance
  cp config/credentials/appliance.* /srv/ontoportal/virtual_appliance/appliance_config/bioportal_web_ui/config/credentials/ || exit 1
popd
