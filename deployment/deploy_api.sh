#!/bin/bash
# wrapper for deploying ontologies_api
# To update ontologies_api you will need to set NCBO_BRANCH to appropriate git repo release/tag 

source $(dirname "$0")/versions
COMPONENT=ontologies_api

export NCBO_BRANCH=$API_RELEASE

pushd $COMPONENT
cap appliance deploy
popd
