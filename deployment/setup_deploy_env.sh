#!/bin/bash
# sets up deployment environment for the appliance
#
# Script pulls various ncbo bioportal repos that it needs for like capistrano scripts
# its a bit of an overkill but is consistent with the way that bioportal stack is deployed in production 
# script locks repos to specific tags which should be compatible with this particular version of appliance

source "$(dirname "$0")/versions"
echo '====> Setting up deployment environment'
bundle config --global set deployment 'true'
bundle config --global set path $BUNDLE_PATH
CONFIG_DIR=$VIRTUAL_APPLIANCE_REPO/appliance_config
cat ~/.bundle/config
# copy default version controlled config files to local config files
[ -e ${CONFIG_DIR}/site_config.rb ] || cp ${CONFIG_DIR}/site_config.rb.default ${CONFIG_DIR}/site_config.rb
[ -e ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb ] || cp ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb.default ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb
[ -e ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb ] || cp ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb.default ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb
[ -e ${CONFIG_DIR}/ncbo_cron/config/config.rb ] || cp ${CONFIG_DIR}/ncbo_cron/config/config.rb.default ${CONFIG_DIR}/ncbo_cron/config/config.rb

# Determine if we need to deploy from a branch or a tag
if [[ $API_RELEASE =~ ^v[0-9.]+ ]] ; then  API_RELEASE=tags/${API_RELEASE} ; fi
if [[ $UI_RELEASE =~ ^v[0-9.]+ ]] ; then UI_RELEASE=tags/${UI_RELEASE} ; fi
if [[ $ONTOLOGIES_LINKED_DATA_RELEASE =~ ^v[0-9.]+ ]] ; then ONTOLOGIES_LINKED_DATA_RELEASE=tags/${ONTOLOGIES_LINKED_DATA_RELEASE} ; fi

echo '=====> Setting up deployment env for UI'
if [ ! -d bioportal_web_ui ]; then
  git clone ${GH}/bioportal_web_ui bioportal_web_ui
fi
pushd bioportal_web_ui
git fetch
git checkout "$UI_RELEASE"

# remove BioPortal specific tagline from locales file
if [ ! -e ${CONFIG_DIR}/bioportal_web_ui/config/locales/en.yml ]; then
 echo "==> tweaking locales file"
 cp config/locales/en.yml ${CONFIG_DIR}/bioportal_web_ui/config/locales
 sed -i "s/the world's most comprehensive repository of biomedical ontologies/your ontology repository for your ontologies/"  ${CONFIG_DIR}/bioportal_web_ui/config/locales/en.yml
fi

# install gems required for deployment, i.e capistrano, rake, etc.  Rails gem is required for generating secret
bundle config set --local deployment 'true'
bundle config set --local path $BUNDLE_PATH
bundle install

# set up encrypted credentials, rails v5.2 is required"
if [ ! -f ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/credentials/appliance.yml.enc ]; then
  echo "====> resetting rails credentials"
  EDITOR='echo "secret_key_base: $(bundle exec rake secret)" > ' bundle exec rails credentials:edit --environment appliance
  if [ $? -ne 0 ]; then
    echo "==>  Unable to generate secret !!!"
    exit
  fi
  cp config/credentials/appliance.* ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/credentials/
fi
popd

echo '=====> Setting up deployment env for API'
if [ ! -d ontologies_api ]; then 
  git clone ${GH}/ontologies_api ontologies_api
fi

pushd ontologies_api
git fetch
git checkout "$API_RELEASE"
#install gems required for deployment, i.e capistrano, rake, etc. 
bundle config set --local path $BUNDLE_PATH
bundle config set --local deployment 'true'
bundle config set --local with 'development'
bundle config set --local without 'default:test'

bundle install
bundle binstubs --all
popd

if [ ! -d ${VIRTUAL_APPLIANCE_REPO}/appliance_config/ontologies_linked_data ]; then
  git clone ${GH}/ontologies_linked_data ${VIRTUAL_APPLIANCE_REPO}/appliance_config/ontologies_linked_data
fi
pushd ${VIRTUAL_APPLIANCE_REPO}/appliance_config/ontologies_linked_data
git fetch
git checkout "$ONTOLOGIES_LINKED_DATA_RELEASE"
popd
