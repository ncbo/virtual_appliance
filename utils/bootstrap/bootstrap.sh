#!/bin/bash
OP_PATH=/opt/ontoportal
sudo opstop
sudo systemctl start 4s-boss
./kb_bootstrap_create_kb.sh
pushd ${OP_PATH}/virtual_appliance/deployment
./setup_deploy_env.sh
./deploy_all.sh
sudo opstart
sudo opstatus -v
popd

# set up maintanence page which will remain in palce untill firstboot.rb removes it.
cp ${OP_PATH}/virtual_appliance/utils/bootstrap/maintenance.html ${OP_PATH}/bioportal_web_ui/current/public/system

./kb_bootstrap_accounts.sh

# bioportal_ontology_import script fails to create submission during aws ami packaging for some unknown reason.
#ruby ../bioportal_ontologies_import.rb
ruby load_STY_ontology.rb

pushd ${OP_PATH}/ncbo_cron
bin/ncbo_ontology_process -o STY
popd
