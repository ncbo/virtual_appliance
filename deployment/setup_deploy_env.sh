#!/bin/bash
# sets up deployment environment for the appliance
#
# Script pulls various ncbo bioportal repos that it needs for like capistrano scripts
# its a bit of an overkill but is consistent with the way that bioportal stack is deployed in production 
# script locks repos to specific tags which should be compatible with this particular version of appliance

source $(dirname "$0")/versions

#install capistrano gems required for deployment
gem install capistrano -v=3.8.2 --user-install
gem install capistrano-locally --user-install
gem install capistrano-bundler --user-install
gem install bundler -v=1.17.3 --user-install
gem install bundler -v=2.0.1 --user-install
gem install capistrano-rails --user-install


#Determine if we need to deploy from a branch or a tag
if [[ $API_RELEASE =~ ^v[0-9.]+ ]] ; then  API_RELEASE=tags/$API_RELEASE ; fi
if [[ $UI_RELEASE =~ ^v[0-9.]+ ]] ; then UI_RELEASE=tags/$UI_RELEASE ; fi
if [[ $ONTOLOGIES_LINKED_DATA_RELEASE =~ ^v[0-9.]+ ]] ; then ONTOLOGIES_LINKED_DATA_RELEASE=tags/$ONTOLOGIES_LINKED_DATA_RELEASE ; fi

if [ ! -d bioportal_web_ui ]; then
  git clone https://github.com/ncbo/bioportal_web_ui bioportal_web_ui
fi
pushd bioportal_web_ui
git pull
git checkout "$UI_RELEASE"
popd

if [ ! -d ontologies_api ]; then 
  git clone https://github.com/ncbo/ontologies_api ontologies_api
fi
pushd ontologies_api
git pull
git checkout "$API_RELEASE"
popd

if [ ! -d ../appliance_config/ontologies_linked_data ]; then
  git clone https://github.com/ncbo/ontologies_linked_data ../appliance_config/ontologies_linked_data
fi
pushd ../appliance_config/ontologies_linked_data
git pull
git checkout "$ONTOLOGIES_LINKED_DATA_RELEASE"
popd
