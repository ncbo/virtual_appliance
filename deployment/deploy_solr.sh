#!/usr/bin/env bash
#
# OntoPortal Appliance script for updating solr configuraion


source $(dirname "$0")/versions

LOCAL_CONFIG_PATH=$VIRTUAL_APPLIANCE_REPO/appliance_config
COMPONENT=ontologies_linked_data
NCBO_BRANCH=$ONTOLOGIES_LINKED_DATA_RELEASE
SORL_CONF=$LOCAL_CONFIG_PATH/$COMPONENT/config/solr

echo "deploying SOLR config from $NCBO_BRANCH branch of ontologies_linked_data"
pushd ../appliance_config/ontologies_linked_data/

git pull
git checkout tags/$NCBO_BRANCH
git branch
popd

rsync -avr $SORL_CONF/* /srv/solr/config

sudo systemctl restart solr
