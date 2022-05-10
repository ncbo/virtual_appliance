#!/bin/bash
#
# OntoPortal Appliance deployment wrapper for OntoPortal Web UI
# https://github.com/ncbo/bioportal_web_ui
# Script sets up deployment environment and runs capistrano deployment job

#source versions
source $(dirname "$0")/versions

COMPONENT=bioportal_web_ui
export BRANCH=$UI_RELEASE

echo "====> deploying $COMPONENT from $BRANCH branch"

# copy site config which contains customised settings for the appliance 
if  [ -f  "${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb" ]; then
 echo 'copying local site overrides file'
 cp -v ${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb ${VIRTUAL_APPLIANCE_REPO}/appliance_config/${COMPONENT}/config
fi

if [ ! -d $COMPONENT ]; then
  echo "===> Repo for $COMPONENT is not available.  Please run setup_deploy_env.sh"
  exit 1
fi

pushd $COMPONENT
# installing correct version of bundler
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --user-install

# install capistrano for running deployment rake task
bundle install
bundle exec cap appliance deploy
popd
