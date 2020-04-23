#!/bin/bash
sudo opstop
sudo service agraph start
./bootstrap_create_AG_repository.sh
pushd /srv/ontoportal/virtual_appliance/deployment
sh setup_deploy_env.sh
sh deploy_all.sh
sudo opstart
popd
./kb_bootstrap_accounts.sh
ruby ../bioportal_ontologies_import.rb
pushd /srv/ontoportal/ncbo_cron
bin/ncbo_ontology_process -o STY
popd
