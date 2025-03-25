#!/usr/bin/env bash
#
# A simple script to install Puppet 7 on Ubuntu 22.04 (Jammy) from the Puppet repository
# and then clone OnotPortal control-repo from GitHub.

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root"
  exit 1
fi

echo "==> Adding Puppet 7 repository..."
# Download and install Puppet's release package for Ubuntu 22.04 (Jammy)
wget -q -O /tmp/puppet7-release-jammy.deb https://apt.puppet.com/puppet7-release-jammy.deb

dpkg -i /tmp/puppet7-release-jammy.deb
rm -f /tmp/puppet7-release-jammy.deb
apt-get update -y
apt-get install -y puppet-agent

echo "==> Cloning the control-repo from GitHub..."
# Replace with your actual GitHub URL and desired path
git clone https://github.com/ontoportal/ontoportal-appliance-puppet-control-repo /etc/puppetlabs/code/environments/production

cd /etc/puppetlabs/code/environments/production
bundle install
r10k puppetfile install -v

echo "==> Puppet 7 installation and control-repo clone completed."

