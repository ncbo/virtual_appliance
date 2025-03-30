#!/bin/bash
#
# OntoPortal Appliance deployment script for ncbo_cron
# https://github.com/ncbo/ncbo_cron

source "$(dirname "$0")/config.sh"
source "${VIRTUAL_APPLIANCE_REPO}/utils/git_helpers.sh"

COMPONENT=ncbo_cron
RELEASE=$NCBO_CRON_RELEASE
LOCAL_CONFIG_PATH=${VIRTUAL_APPLIANCE_REPO}/appliance_config

echo "====> deploying $COMPONENT from $RELEAS branch"
sudo /bin/systemctl stop $COMPONENT
pushd ${APP_DIR}
checkout_release "$COMPONENT" "$RELEASE"
cd $COMPONENT
echo 'bundle config'
bundle config --local set deployment 'true'
bundle config set --local path $BUNDLE_PATH
bundle install

rsync -avr ${LOCAL_CONFIG_PATH}/${COMPONENT}/* ${APP_DIR}/${COMPONENT}
popd
sudo /bin/systemctl start "$COMPONENT"
echo "Deployment of $COMPONENT is done"
