#!/bin/bash
# sets up deployment environment for the appliance
#
# Script pulls various ncbo bioportal repos that it needs for the capistrano deployment
# its a bit of an overkill but is consistent with the way that bioportal stack is deployed in production 
# script locks repos to specific tags which should be compatible with this particular version of appliance

#generate_secret_key_base() {
#  echo $(bundle exec rails secret)
#}

source "$(dirname "$0")/config.sh"

echo '====> Setting up deployment environment'
bundle config set --global no-document 'true'
bundle config --global set path $BUNDLE_PATH

CONFIG_DIR=$VIRTUAL_APPLIANCE_REPO/appliance_config
cat ~/.bundle/config

# copy default version controlled config files to local config files
[ -e ${CONFIG_DIR}/site_config.rb ] || cp ${CONFIG_DIR}/site_config.rb.default ${CONFIG_DIR}/site_config.rb && echo "created initial site_config"
[ -e ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb ] || cp ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb.default ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb
[ -e ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb ] || cp ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb.default ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb
[ -e ${CONFIG_DIR}/ncbo_cron/config/config.rb ] || cp ${CONFIG_DIR}/ncbo_cron/config/config.rb.default ${CONFIG_DIR}/ncbo_cron/config/config.rb

checkout_release() {
    local component="$1"
    local release="$2"
    local repo_url="${GH}/${component}"

    # ANSI color codes
    RED="\e[31m"
    RESET="\e[0m"

    if [[ -z "$component" || -z "$release" ]]; then
        echo -e "${RED}Usage: checkout_release <component> <release>${RESET}"
        return 1
    fi

    # Clone repository if the directory doesn't exist
    if [[ ! -d "$component/.git" ]]; then
        echo "Repository '$component' not found locally. Cloning from $repo_url..."
        if ! git clone "$repo_url" "$component"; then
            echo -e "${RED} Error: Failed to clone repository $repo_url ${RESET}"
            return 1
        fi
    fi

    # Change into the repository directory using pushd
    pushd "$component" > /dev/null || return 1
    echo "Checking out '$release' in $(pwd)..."

    # If release starts with "v" followed by a number, assume it's a tag
    if [[ "$release" =~ ^v[0-9]+ ]]; then
        echo "'$release' looks like a tag, fetching tags..."
        git fetch --tags
        release="tags/$release"  # Modify release for tag checkout
    fi

    # Try to checkout the branch or tag
    if ! git checkout "$release"; then
        echo -e "${RED} "Error: Failed to check out $release. It may not exist.${RESET}""
        popd > /dev/null  # Restore previous directory
        return 1
    fi

    # Restore the previous directory
    popd > /dev/null
}

echo "=====> Setting up deployment env for UI"

checkout_release bioportal_web_ui $UI_RELEASE || exit 1
pushd bioportal_web_ui

# install gems required for deployment, i.e capistrano, rake, etc.  Rails gem is required for generating secret
bundle config set --local deployment 'true'
bundle config set --local path $BUNDLE_PATH
bundle install

echo "!!!!! need to set up creds in ${VIRTUAL_APPLIANCE_REPO} repo"
# set up encrypted credentials, rails v5.2 is required"
if [ ! -f ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/credentials/appliance.yml.enc ]; then
  /opt/ontoportal/virtual_appliance/utils/bootstrap/reset_ui_encrypted_credentials.sh
fi
popd

echo '=====> Setting up deployment env for API'
checkout_release ontologies_api "$API_RELEASE" || exit 1
pushd ontologies_api

#install gems required for deployment, i.e capistrano, rake, etc. 
bundle config set --local path $BUNDLE_PATH
bundle config set --local deployment 'true'
bundle config set --local with 'development'
bundle config set --local without 'default:test'

bundle install
bundle binstubs --all
popd

pushd ${VIRTUAL_APPLIANCE_REPO}/appliance_config
checkout_release ontologies_linked_data "$ONTOLOGIES_LINKED_DATA_RELEASE"
popd
