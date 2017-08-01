#Script for updating solr configuration for NCBO BioPortal
#

source $(dirname "$0")/versions

COMPONENT=ontologies_linked_data
NCBO_BRANCH=$ONTOLOGIES_LINKED_DATA_RELEASE
SORL_CONF=$LOCAL_CONFIG_PATH/$COMPONENT/config/solr
git pull
git checkout tags/$NCBO_BRANCH 

rsync -avr $SORL_CONF/* /srv/solr/config

#sudo service tomcat restart
