#!/bin/bash
# update ncbo_cron component

source $(dirname "$0")/versions

if [[ $NCBO_CRON_RELEASE =~ ^v[0-9.]+ ]] ; then  $NCBO_CRON_RELEASE=tags/$NCBO_CRON_RELEASE ; fi

COMPONENT=ncbo_cron
VIRTUAL_APPLIANCE_REPO=/srv/virtual_appliance
export NCBO_BRANCH=$NCBO_CRON_RELEASE
LOCAL_CONFIG_PATH=$VIRTUAL_APPLIANCE_REPO/appliance_config


echo "deploying ncbo_cron from $NCBO_BRANCH branch"
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
bundle install --deployment
rsync -avr $LOCAL_CONFIG_PATH/$COMPONENT/* /srv/ncbo/ncbo_cron
popd
sudo /bin/systemctl start ncbo_cron
