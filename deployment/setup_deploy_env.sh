#!/bin/bash
# sets up deployment environment for the appliance
#
# Script pulls various ncbo bioportal repos that it needs for like capistrano scripts
# its a bit of an overkill but is consistent with the way that bioportal stack is deployed in production 
# script locks repos to specific tags which should be compatible with this particular version of appliance

source $(dirname "$0")/versions
echo 'Setting up deployment environment'
CONFIG_DIR=$VIRTUAL_APPLIANCE_REPO/appliance_config

# copy default version controlled config files to local config files
[ -e ${CONFIG_DIR}/site_config.rb ] || cp ${CONFIG_DIR}/site_config.rb.default ${CONFIG_DIR}/site_config.rb
[ -e ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb ] || cp ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb.default ${CONFIG_DIR}/bioportal_web_ui/config/bioportal_config_appliance.rb
[ -e ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb ] || cp ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb.default ${CONFIG_DIR}/ontologies_api/config/environments/appliance.rb
[ -e ${CONFIG_DIR}/ncbo_cron/config/config.rb ] || cp ${CONFIG_DIR}/ncbo_cron/config/config.rb.default ${CONFIG_DIR}/ncbo_cron/config/config.rb


# Determine if we need to deploy from a branch or a tag
if [[ $API_RELEASE =~ ^v[0-9.]+ ]] ; then  API_RELEASE=tags/${API_RELEASE} ; fi
if [[ $UI_RELEASE =~ ^v[0-9.]+ ]] ; then UI_RELEASE=tags/${UI_RELEASE} ; fi
if [[ $ONTOLOGIES_LINKED_DATA_RELEASE =~ ^v[0-9.]+ ]] ; then ONTOLOGIES_LINKED_DATA_RELEASE=tags/${ONTOLOGIES_LINKED_DATA_RELEASE} ; fi
echo 'Setting up deployment env for UI'
if [ ! -d bioportal_web_ui ]; then
  git clone https://github.com/ncbo/bioportal_web_ui bioportal_web_ui
fi
pushd bioportal_web_ui
git fetch
git checkout "$UI_RELEASE"

# remove BioPortal specific tagline from locales file
if [ ! -e ${CONFIG_DIR}/bioportal_web_ui/config/locales/en.yml ]; then
 echo "tweaking locales file"
 cp config/locales/en.yml ${CONFIG_DIR}/bioportal_web_ui/config/locales
 sed -i "s/the world's most comprehensive repository of biomedical ontologies/your ontology repository for your ontologies/"  ${CONFIG_DIR}/bioportal_web_ui/config/locales/en.yml
fi

# Install exact version of bundler as required
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --user-install --no-ri --no-rdoc

# install gems required for deployment, i.e capistrano, rake, etc.  Rails gem is required for generate secret
bundle install --with default development --deployment
if [ ! -f ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/secrets.yml ]; then
  SECRET=$(bundle exec rake secret)
  if [ $? -ne 0 ]; then
    echo "YIKES!!!! unable to generate secret!!"
    exit $?
  fi
  cat <<EOF > ${VIRTUAL_APPLIANCE_REPO}/appliance_config/bioportal_web_ui/config/secrets.yml 
appliance:
  secret_key_base: $SECRET
EOF
fi
popd

echo 'Setting up deployment env for API'
if [ ! -d ontologies_api ]; then 
  git clone https://github.com/ncbo/ontologies_api ontologies_api
fi
pushd ontologies_api
git fetch
git checkout "$API_RELEASE"
# Install exact version of bundler as required
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --user-install --no-ri --no-rdoc
#install gems required for deployment, i.e capistrano, rake, etc. 
bundle install --with development --without default --deployment --binstubs
popd

if [ ! -d ${VIRTUAL_APPLIANCE_REPO}/appliance_config/ontologies_linked_data ]; then
  git clone https://github.com/ncbo/ontologies_linked_data ${VIRTUAL_APPLIANCE_REPO}/appliance_config/ontologies_linked_data
fi
pushd ${VIRTUAL_APPLIANCE_REPO}/appliance_config/ontologies_linked_data
git fetch
git checkout "$ONTOLOGIES_LINKED_DATA_RELEASE"
popd
