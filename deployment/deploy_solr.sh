#Script for updating solr configuration for NCBO BioPortal
#

source $(dirname "$0")/versions

LOCAL_CONFIG_PATH=$VIRTUAL_APPLIANCE_REPO/appliance_config
COMPONENT=ontologies_linked_data
NCBO_BRANCH=$ONTOLOGIES_LINKED_DATA_RELEASE
SORL_CONF=$LOCAL_CONFIG_PATH/$COMPONENT/config/solr

pushd ../appliance_config/ontologies_linked_data/
git pull
git checkout tags/$NCBO_BRANCH
git branch
popd

rsync -avr $SORL_CONF/* /srv/solr/data/config

sudo systemctl restart solr
