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
sudo bash "${VA}/utils/infra/run_masterless_puppet.sh r10k"

# FIXME: need to run puppet 2nd time, rbenv fails to install firt time
log "📦 Running masterless puppet to provsion infrastructure..."
sudo bash "${VA}/utils/infra/run_masterless_puppet.sh"

# === Step 2: Application provisioning ===
log "🚀 Running application provisioning (bootstrap appliance with AllegroGraph)..."
sudo chown -R op-admin:op-admin $VA

if ! sudo -u op-admin bash -l -c "cd '${VA}/utils/bootstrap' && ./bootstrap_AG.sh"; then
  echo "❌ AllegroGraph bootstrap failed"
  exit 1
fi

log "✅ Server bootstrap entrypoint completed successfully."
