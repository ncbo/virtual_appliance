#!/bin/bash
# wrapper for deploying Bioportal Web UI
# it uses capistrano deployment framework which is used for deploying bioontology.org
# To update Web UI you will need to set NCBO_BRANCH to the appropriate git repo release/tag

#source versions
source $(dirname "$0")/versions

COMPONENT=bioportal_web_ui

export NCBO_BRANCH=$UI_RELEASE

# copy site config which contains customised settings for the appliance 
if  [ -f  '../appliance_config/site_config.rb' ]; then
 cp ../appliance_config/site_config.rb ../appliance_config/${COMPONENT}/config
 echo 'copying site overides file'
fi

pushd $COMPONENT

# run capistrano deployment task
cap appliance deploy
popd
