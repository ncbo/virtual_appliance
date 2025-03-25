#!/usr/bin/env bash
#
# A simple script to install Puppet 7 on Ubuntu 22.04 (Jammy) from the Puppet repository
# and then clone OntoPortal control-repo from GitHub.

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root"
  exit 1
fi

# Set environment variables so apt/dpkg won't prompt for input:
#  - DEBIAN_FRONTEND=noninteractive prevents package configuration dialogs.
#  - NEEDRESTART_SUSPEND=1 prevents needrestart from prompting to restart services.
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=1

echo "==> Adding Puppet 7 repository..."
# Download and install Puppet's release package for Ubuntu 22.04 (Jammy)
wget -q -O /tmp/puppet7-release-jammy.deb https://apt.puppet.com/puppet7-release-jammy.deb

dpkg -i /tmp/puppet7-release-jammy.deb
rm -f /tmp/puppet7-release-jammy.deb
apt-get update
apt-get install -y puppet-agent

echo "==> Cloning the control-repo from GitHub..."
git clone https://github.com/ontoportal/ontoportal-appliance-puppet-control-repo /etc/puppetlabs/code/environments/production

cd /etc/puppetlabs/code/environments/production

/opt/puppetlabs/puppet/bin/gem install r10k -v '~> 3.16'
/opt/puppetlabs/puppet/bin/r10k puppetfile install -v

echo "==> Puppet 7 installation and control-repo clone completed."
