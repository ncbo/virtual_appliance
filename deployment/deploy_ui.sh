#!/bin/bash
# wrapper for deploying Bioportal Web UI
# To update Web UI you will need to set NCBO_BRANCH to the appropriate git repo release/tag

#source versions
source $(dirname "$0")/versions

COMPONENT=bioportal_web_ui

export NCBO_BRANCH=$UI_RELEASE

pushd $COMPONENT
cap appliance deploy
popd
