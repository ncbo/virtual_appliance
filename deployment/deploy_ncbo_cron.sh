#!/bin/bash
# update ncbo_cron component

source $(dirname "$0")/versions

COMPONENT=ncbo_cron
VIRTUAL_APPLIANCE_REPO=~/virtual_appliance
export NCBO_BRANCH=$NCBO_CRON_RELEASE
LOCAL_CONFIG_PATH=$VIRTUAL_APPLIANCE_REPO/appliance_config

if [ -d /srv/ncbo/ncbo_cron ]; then
  pushd /srv/ncbo/ncbo_cron
  git pull
else 
  git clone https://github.com/ncbo/ncbo_cron /srv/ncbo/ncbo_cron
  pushd /srv/ncbo/ncbo_cron
fi
git checkout tags/$NCBO_BRANCH
bundle install --deployment
rsync -avr $LOCAL_CONFIG_PATH/$COMPONENT/* /srv/ncbo/ncbo_cron
popd
