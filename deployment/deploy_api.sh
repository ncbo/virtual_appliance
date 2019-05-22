#!/bin/bash
# wrapper for deploying ontologies_api
# To update ontologies_api you will need to set NCBO_BRANCH to appropriate git repo release/tag 

source $(dirname "$0")/versions
COMPONENT=ontologies_api

export NCBO_BRANCH=$API_RELEASE
# copy site config which contains customised settings for the appliance

if  [ -f  '../appliance_config/site_config.rb' ]; then
 cp ../appliance_config/site_config.rb ../appliance_config/${COMPONENT}/config/environments
 echo 'copying site overides file'
fi

pushd $COMPONENT
bundle exec cap appliance deploy
popd
