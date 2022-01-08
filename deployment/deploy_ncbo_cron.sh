#!/bin/bash
# OntoPortal Appliance deployment script for ncbo_cron
# https://github.com/ncbo/ncbo_cron

source $(dirname "$0")/versions

COMPONENT=ncbo_cron
#export BRANCH=$NCBO_CRON_RELEASE
BRANCH=$NCBO_CRON_RELEASE
LOCAL_CONFIG_PATH=${VIRTUAL_APPLIANCE_REPO}/appliance_config

echo "====> deploying $COMPONENT from $BRANCH branch"
sudo /bin/systemctl stop $COMPONENT
if [ -d ${APP_DIR}/$COMPONENT/bin ]; then
  pushd ${APP_DIR}/$COMPONENT
  git pull
else 
  git clone https://github.com/ncbo/${COMPONENT} ${APP_DIR}/${COMPONENT}
  pushd ${APP_DIR}/${COMPONENT}
fi
git fetch
git checkout "$NCBO_CRON_RELEASE"
# Install the exact version of bundler as required
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --user-install
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
