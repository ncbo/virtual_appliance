#!/bin/bash

sudo opstop
sudo systemctl start 4s-boss
./kb_bootstrap_create_kb.sh
pushd /srv/ncbo/virtual_appliance/deployment
sh setup_deploy_env.sh
sh deploy_all.sh
sudo opstart
popd
./kb_bootstrap_accounts.sh
ruby ../bioportal_ontologies_import.rb
pushd /srv/ncbo/ncbo_cron
bin/ncbo_ontology_process -o STY
popd
