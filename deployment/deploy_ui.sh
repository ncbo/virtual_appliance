#!/bin/bash
#
# OntoPortal Appliance deployment wrapper for OntoPortal Web UI
# https://github.com/ncbo/bioportal_web_ui
# Script sets up deployment environment and runs capistrano deployment job

#source versions
source $(dirname "$0")/versions

COMPONENT=bioportal_web_ui
export NCBO_BRANCH=$UI_RELEASE

echo "deploying $COMPONENT from $NCBO_BRANCH branch"

# copy site config which contains customised settings for the appliance 
if  [ -f  "${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb" ]; then
 echo 'copying local site overides file'
 cp ${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb ${VIRTUAL_APPLIANCE_REPO}/appliance_config/${COMPONENT}/config
fi

pushd $COMPONENT

# install capistrano for running deployment rake task
bundle install --with development --without default --deployment
bundle exec cap appliance deploy
popd
