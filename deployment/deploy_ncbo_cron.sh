#!/bin/bash
# OntoPortal Appliance deployment script for ncbo_cron
# https://github.com/ncbo/ncbo_cron

source $(dirname "$0")/versions

COMPONENT=ncbo_cron
export NCBO_BRANCH=$NCBO_CRON_RELEASE
LOCAL_CONFIG_PATH=$VIRTUAL_APPLIANCE_REPO/appliance_config

echo "deploying $COMPONENT from $NCBO_BRANCH branch"
sudo /bin/systemctl stop ncbo_cron
if [ -d /srv/ncbo/ncbo_cron/bin ]; then
  pushd /srv/ncbo/ncbo_cron
  git pull
else 
  git clone https://github.com/ncbo/ncbo_cron /srv/ncbo/ncbo_cron
  pushd /srv/ncbo/ncbo_cron
fi
git fetch
git checkout $NCBO_CRON_RELEASE
# Install the exact version of bundler as required
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --user-install --no-ri --no-rdoc
bundle install --deployment

# Copy config files
rsync -avr $LOCAL_CONFIG_PATH/$COMPONENT/* /srv/ncbo/ncbo_cron
popd
sudo /bin/systemctl start ncbo_cron
echo "Deployment of $COMPONENT is done"
