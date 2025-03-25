#!/usr/bin/env bash
# ontoportal appliance orchestration script,
# provisions infrastrucuture, installs app, import data, etc
set -euo pipefail

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

VA="/opt/ontoportal/virtual_appliance"

# === Step 1: Puppet-based infra provisioning ===
log "📦 Installing puppet..."
sudo bash "${VA}/utils/infra/install_puppet.sh"

log "📦 Running masterless puppet to provsion infrastructure..."
sudo bash "${VA}/utils/infra/run_masterless_puppet.sh"

# === Step 2: Application provisioning ===
log "🚀 Running application provisioning (bootstrap appliance with AllegroGraph)..."
sudo chown -R ontoportal:ontoportal $VA
sudo -u ontoportal bash -l -c "${VA}/utils/bootstrap/bootstrap_AG.sh"

log "✅ Server bootstrap entrypoint completed successfully."
