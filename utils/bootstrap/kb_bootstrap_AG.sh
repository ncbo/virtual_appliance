#!/bin/bash
#  !!!!!!!! AG licence is required !!!!!!!

sudo opstop
sudo service agraph start
./bootstrap_create_AG_repository.sh
sudo opstart
./kb_bootstrap_accounts.sh
ruby ../bioportal_ontologies_import.rb
pushd /srv/ontoportal/ncbo_cron
bin/ncbo_ontology_process -o STY
popd
