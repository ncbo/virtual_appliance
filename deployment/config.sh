#!/bin/bash
# This file contains a list of variables as sourced in the deployment wrapper scripts
# <component>_RELEASE corresponds to the version of a component such as UI or API
# installed in the virtual appliance
# RELEASE numbers have to be compatible with this version of the appliance stack

# Ensure this file is only sourced, not executed
(return 0 2>/dev/null) || {
  echo "ERROR: This script must be sourced, not executed."
  exit 1
}

# General settings
export DATA_DIR="/srv/ontoportal"
export APP_DIR="/opt/ontoportal"
export VIRTUAL_APPLIANCE_REPO="/opt/ontoportal/virtual_appliance"
export BUNDLE_PATH="/opt/ontoportal/.bundle"
export ADMIN_USER="op-admin"

source "$(dirname "$0")/versions"

# Check for correct user
if [[ "$USER" != $ADMIN_USER ]]; then
  echo "ERROR: You need to run this script as the $ADMIN_USER user"
  exit 1
fi

# General settings
export DATA_DIR="/srv/ontoportal"
export APP_DIR="/opt/ontoportal"
export VIRTUAL_APPLIANCE_REPO="/opt/ontoportal/virtual_appliance"
export BUNDLE_PATH="/opt/ontoportal/.bundle"
export ADMIN_USER="op-admin"

# export LOCAL_CONFIG_PATH="${VIRTUAL_APPLIANCE_REPO}/appliance_config"

# GitHub settings
export GH_ORG='ncbo'
export GH="https://github.com/${GH_ORG}"
