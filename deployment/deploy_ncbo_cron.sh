#!/bin/bash
#
# OntoPortal Appliance deployment script for ncbo_cron
# https://github.com/ncbo/ncbo_cron

source "$(dirname "$0")/versions"
COMPONENT=ncbo_cron

BRANCH=$NCBO_CRON_RELEASE
LOCAL_CONFIG_PATH=${VIRTUAL_APPLIANCE_REPO}/appliance_config

echo "====> deploying $COMPONENT from $BRANCH branch"
sudo /bin/systemctl stop $COMPONENT
if [ -d ${APP_DIR}/$COMPONENT/bin ]; then
  pushd ${APP_DIR}/$COMPONENT
  git pull
else 
  git clone ${GH}/${COMPONENT} ${APP_DIR}/${COMPONENT}
  pushd ${APP_DIR}/${COMPONENT}
fi
git fetch
git checkout "$NCBO_CRON_RELEASE"
echo 'orig bundle config'
bundle config --local set deployment 'true'
bundle config set --local path $BUNDLE_PATH
bundle install

# Copy config files
if  [ -f  "${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb" ]; then
 echo '===> copying site overrides file'
 cp -v ${VIRTUAL_APPLIANCE_REPO}/appliance_config/site_config.rb ${VIRTUAL_APPLIANCE_REPO}/appliance_config/${COMPONENT}/config
fi
rsync -avr ${LOCAL_CONFIG_PATH}/${COMPONENT}/* ${APP_DIR}/${COMPONENT}
popd
sudo /bin/systemctl start "$COMPONENT"
echo "Deployment of $COMPONENT is done"
