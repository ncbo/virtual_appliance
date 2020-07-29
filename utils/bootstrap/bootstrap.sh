#!/bin/bash
sudo opstop
sudo systemctl start 4s-boss
./kb_bootstrap_create_kb.sh
pushd /srv/ontoportal/virtual_appliance/deployment
sh setup_deploy_env.sh
sh deploy_all.sh
sudo opstart
popd
./kb_bootstrap_accounts.sh
ruby ../bioportal_ontologies_import.rb
pushd /srv/ontoportal/ncbo_cron
bin/ncbo_ontology_process -o STY
cp maintenance.html /srv/ontoportal/bioportal_web_ui/current/public/maintenance.html
popd
