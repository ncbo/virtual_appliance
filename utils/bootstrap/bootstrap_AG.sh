#!/bin/bash
OP_PATH=/opt/ontoportal

if [ "$USER" != 'op-admin' ]; then
  echo "you need to run this script as ontoportal user"
  exit 1
fi

sudo opctl stop

./bootstrap_create_AG_repository.sh
pushd ${OP_PATH}/virtual_appliance/deployment
./setup_deploy_env.sh
./deploy_all.sh

sudo opctl start
popd

# set up maintanence page which will remain in palce untill firstboot.rb removes it.
cp ${OP_PATH}/virtual_appliance/utils/bootstrap/maintenance.html ${OP_PATH}/bioportal_web_ui/current/public/system

./kb_bootstrap_accounts.sh
ruby load_STY_ontology.rb

pushd ${OP_PATH}/ncbo_cron
bin/ncbo_ontology_process -o STY
# run metrics; remove after https://github.com/ncbo/ncbo_cron/issues/82 is fixed
bin/ncbo_ontology_process -o STY -t run_metrics
popd
