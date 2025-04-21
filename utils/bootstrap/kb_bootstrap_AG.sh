#!/bin/bash
#  !!!!!!!! AG licence is required !!!!!!!

sudo opctl stop
sudo service agraph start
./bootstrap_create_AG_repository.sh
sudo opctl start 
./kb_bootstrap_accounts.sh
ruby ../bioportal_ontologies_import.rb
pushd /opt/ontoportal/ncbo_cron
bin/ncbo_ontology_process -o STY
popd
