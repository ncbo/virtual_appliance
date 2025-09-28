#!/bin/bash
# Sets up deployment environment for the appliance
#
# Script pulls various NCBO BioPortal repos that it needs for the Capistrano deployment.
# It locks repos to specific tags which should be compatible with this particular version of the appliance.

set -euo pipefail

source "$(dirname "$0")/config.sh"
source "${VIRTUAL_APPLIANCE_REPO}/utils/git_helpers.sh"

# Ensure required environment variables are set
: "${BUNDLE_PATH:?Must set BUNDLE_PATH in config.sh}"
: "${VIRTUAL_APPLIANCE_REPO:?Must set VIRTUAL_APPLIANCE_REPO in config.sh}"
: "${GH:?Must set GH (GitHub org/url prefix) in config.sh}"

echo '====> Setting up deployment environment'
mkdir -p ~/.bundle
bundle config set --global no-document 'true'
bundle config set --global path "$BUNDLE_PATH"

# Config files for deployment
CONFIG_DIR="$VIRTUAL_APPLIANCE_REPO/appliance_config"

SITE_CONFIG="/opt/ontoportal/config/site_config.rb"
API_CONFIG="${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb"
UI_CONFIG="${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb"
CRON_CONFIG="${CONFIG_DIR}/ncbo_cron/config/config.rb"

[ -e "${SITE_CONFIG}" ] || cp "${CONFIG_DIR}/site_config.rb.default" "${SITE_CONFIG}" && echo "created initial ${SITE_CONFIG}"
[ -e "${UI_CONFIG}" ] || cp "${UI_CONFIG}.default" "${UI_CONFIG}" && echo "created ${UI_CONFIG}"
[ -e "${API_CONFIG}" ] || cp "${API_CONFIG}.default" "${API_CONFIG}" && echo "created ${API_CONFIG}"
[ -e "${CRON_CONFIG}" ] || cp "${CRON_CONFIG}.default" "${CRON_CONFIG}" && echo "created ${CRON_CONFIG}"

# we are using Capistrano for deployments of the UI and API
# so we need to set up env where we can run deployments from using existing
# capistrano scripts
echo "=====> Setting up deployment env for UI"
checkout_release bioportal_web_ui "$UI_RELEASE"
pushd bioportal_web_ui > /dev/null

# copy config files to deploy directory, just in case we have deploy overrides
rsync -av ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/* .

bundle config set --local deployment 'true'
bundle config set --local path "$BUNDLE_PATH"
bundle install

echo "Setting up encrypted creds in ${VIRTUAL_APPLIANCE_REPO} repo"
if [ ! -f "${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/credentials/appliance.yml.enc" ]; then
  "${VIRTUAL_APPLIANCE_REPO}/utils/bootstrap/reset_ui_encrypted_credentials.sh"
fi
popd > /dev/null

echo "=====> Setting up deployment env for API"
checkout_release ontologies_api "$API_RELEASE"
pushd ontologies_api > /dev/null

bundle config set --local path "$BUNDLE_PATH"
bundle config set --local deployment 'true'
bundle config set --local with 'development'
bundle config set --local without 'default:test'

bundle install
popd > /dev/null

pushd "${VIRTUAL_APPLIANCE_REPO}/appliance_config" > /dev/null
checkout_release ontologies_linked_data "$ONTOLOGIES_LINKED_DATA_RELEASE"
popd > /dev/null

