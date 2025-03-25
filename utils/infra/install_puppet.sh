#!/usr/bin/env bash
set -euo pipefail

# === Puppet Infrastructure Bootstrap Script ===
# Installs Puppet 7 on Ubuntu 22.04 and sets up the OntoPortal control-repo

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Ensure the script is run as root
if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run this script as root"
  exit 1
fi

# === Config ===
CONTROL_REPO_DIR="/etc/puppetlabs/code/environments/production"
PUPPET_RELEASE_DEB="/tmp/puppet7-release-jammy.deb"
PUPPET_REPO_URL="https://apt.puppet.com/puppet7-release-jammy.deb"
CONTROL_REPO_URL="https://github.com/ontoportal/ontoportal-appliance-puppet-control-repo"

# Prevent prompts during install
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=1

# === Install Puppet ===
log "📦 Installing Puppet 7 and adding APT repo..."

wget -q -O "${PUPPET_RELEASE_DEB}" "${PUPPET_REPO_URL}"
dpkg -i "${PUPPET_RELEASE_DEB}"
rm -f "${PUPPET_RELEASE_DEB}"

apt-get update
apt-get install -y puppet-agent

# === Clone Control Repo ===
if [[ -d "${CONTROL_REPO_DIR}" ]]; then
  log "🧹 Removing existing control repo at ${CONTROL_REPO_DIR}..."
  rm -rf "${CONTROL_REPO_DIR}"
fi

log "📥 Cloning control-repo from GitHub..."
git clone "${CONTROL_REPO_URL}" "${CONTROL_REPO_DIR}"
cd "${CONTROL_REPO_DIR}"

# === Install modules via r10k ===
log "🔧 Installing r10k and Puppet modules..."
/opt/puppetlabs/puppet/bin/gem install r10k -v '~> 3.16'
/opt/puppetlabs/puppet/bin/r10k puppetfile install -v

log "✅ Puppet installation and control-repo setup complete."

