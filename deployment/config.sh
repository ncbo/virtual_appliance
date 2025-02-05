#!/bin/bash
# This file contains a list of variables as sourced in the deployment wrapper scripts
# <component>_RELEASE corresponds to the version of a component such as UI or API
# installed in the virtual appliance
# RELEASE numbers have to be compatible with this verision of the appliance stack
#

source "$(dirname "$0")/versions"

# general settings
export DATA_DIR="/srv/ontoportal/data"
export APP_DIR="/opt/ontoportal"
VIRTUAL_APPLIANCE_REPO="/opt/ontoportal/virtual_appliance"
export BUNDLE_PATH='/opt/ontoportal/.bundle'
#export LOCAL_CONFIG_PATH=$VIRTUAL_APPLIANCE_REPO/appliance_config

# GitHub settings
GH_ORG='ncbo'
GH="https://github.com/${GH_ORG}"


if [ "$USER" != 'ontoportal' ]; then
  echo "you need to run this script as ontoportal user"
  exit 1
fi

echo GH is $GH
echo DATA_DIR is $DATA_DIR
