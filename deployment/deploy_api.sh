#!/bin/bash
#
# OntoPortal Appliance deployment wrapper for ontologies_api
# https://github.com/ncbo/ontologies_api
# Script sets up deployment environment and runs capistrano deployment job

source $(dirname "$0")/versions
COMPONENT=ontologies_api

export BRANCH=$API_RELEASE
echo "====> deploying $COMPONENT from $BRANCH branch"

# copy site config which contains customised settings for the appliance

if  [ -f  "${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb" ]; then
 echo 'copying site overrides file'
 cp -v ${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb ${VIRTUAL_APPLIANCE_REPO}/appliance_config/${COMPONENT}/config/environments
fi

if [ ! -d $COMPONENT ]; then
  echo "===> Repo for $COMPONENT is not available.  Please run setup_deploy_env.sh"
  exit 1
fi

pushd $COMPONENT
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --user-install
bundle install --binstubs

bundle exec cap appliance deploy
popd
