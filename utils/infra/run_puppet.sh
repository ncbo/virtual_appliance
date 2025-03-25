#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root"
  exit 1
fi

cd /etc/puppetlabs/code/environments/production
/opt/puppetlabs/puppet/bin/r10k puppetfile install -v
/opt/puppetlabs/bin/puppet apply --test --verbose \
     /etc/puppetlabs/code/environments/production/manifests
