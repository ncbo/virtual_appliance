#!/usr/bin/env bash
# ontoportal appliance orchestration script,
# provisions infrastrucuture, installs app, import data, etc
set -euo pipefail

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Absolute base path to all utility scripts
UTILS_BASE="/opt/ontoportal/virtual_appliance/utils"
PUPPET_BOOTSTRAP="${UTILS_BASE}/infra/puppet_infra_bootstrap.sh"
APP_BOOTSTRAP="${UTILS_BASE}/bootstrap/bootstrap_AG.sh"

# === Step 1: Puppet-based infra provisioning ===
log "📦 Installing puppet..."
sudo bash "${UTILS_BASE}/infra/install_puppet.sh"

log "📦 Running masterless puppet to provsion infrastructure..."
sudo bash "${UTILS_BASE}/infra/run_masterless_puppet.sh"

# === Step 2: Application provisioning ===
log "🚀 Running application provisioning (bootstrap appliance with AllegroGraph)..."
sudo bash "${UTILS_BASE}/bootstrap/bootstrap_AG.sh"

log "✅ Server bootstrap entrypoint completed successfully."
