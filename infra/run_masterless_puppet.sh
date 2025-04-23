#!/usr/bin/env bash
set -euo pipefail

# === Config ===
CONTROL_REPO_DIR="/etc/puppetlabs/code/environments/production"
ENV_DIR="/etc/puppetlabs/code/environments"
MANIFEST="${CONTROL_REPO_DIR}/manifests/site.pp"
EYAMLKEYDIR="/etc/puppetlabs/puppet/eyaml"
PrivateKey="${EYAMLKEYDIR}/private_key.pkcs7.pem"
PublicKey="${EYAMLKEYDIR}/public_key.pkcs7.pem"
PUPPET_BIN="/opt/puppetlabs/bin/puppet"
R10K_BIN="/opt/puppetlabs/puppet/bin/r10k"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# === Checks ===
if ! command -v "$PUPPET_BIN" &>/dev/null; then
  echo "❌ Puppet binary not found at $PUPPET_BIN"
  exit 1
fi

if ! command -v "$R10K_BIN" &>/dev/null; then
  echo "❌ r10k not found at $R10K_BIN"
  echo "You can install it with:"
  echo "  /opt/puppetlabs/puppet/bin/gem install r10k"
  exit 1
fi

if [[ ! -d "$CONTROL_REPO_DIR" ]]; then
  echo "❌ Control repo not found at $CONTROL_REPO_DIR"
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "❌ site.pp not found at $MANIFEST"
  exit 1
fi

if [[ ! -f "$PrivateKey" || ! -f "$PublicKey" ]]; then
  echo "🔐 ERROR: EYAML encryption keys not found. Please provide:"
  echo "  - $PrivateKey"
  echo "  - $PublicKey"
  exit 1
fi

# === Install modules with r10k ===
cd "$CONTROL_REPO_DIR"
log "📦 Installing Puppet modules with r10k..."
"$R10K_BIN" puppetfile install --verbose --puppetfile "$CONTROL_REPO_DIR/Puppetfile"

# === Run Puppet ===
log "🚀 Running Puppet in masterless mode..."
"$PUPPET_BIN" apply \
  --environment=production \
  --verbose \
  --environmentpath="$ENV_DIR" \
  "$MANIFEST"

log "✅ Puppet apply completed."
