#!/bin/bash
#
# OntoPortal Appliance deployment wrapper for OntoPortal Web UI
# https://github.com/ncbo/bioportal_web_ui
# Script sets up deployment environment and runs capistrano deployment job

#source versions
source "$(dirname "$0")/config.sh"

COMPONENT=bioportal_web_ui
export BRANCH=$UI_RELEASE

echo "====> deploying $COMPONENT from $BRANCH branch"

if [ ! -d $COMPONENT ]; then
  echo "===> Repo for $COMPONENT is not available.  Please run setup_deploy_env.sh"
  exit 1
fi

pushd $COMPONENT

# install capistrano for running deployment rake task
bundle install
bundle exec cap appliance deploy
popd
