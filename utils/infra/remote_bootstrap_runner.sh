#!/usr/bin/env bash
set -euo pipefail

# === Config ===
REMOTE_HOST="${1:-}"
BRANCH="${2:-4.0}" 

GITHUB_REPO_URL="https://github.com/ncbo/virtual_appliance"
VA="/opt/ontoportal/virtual_appliance"
REMOTE_BOOTSTRAP="${VA}/utils/infra/server_bootstrap_entrypoint.sh"

PRIVATE_KEY_PATH="puppet_eyaml_keys/private_key.pkcs7.pem"
PUBLIC_KEY_PATH="puppet_eyaml_keys/public_key.pkcs7.pem"
REMOTE_KEY_DIR="/etc/puppetlabs/puppet/eyaml"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# === Argument check ===
if [[ -z "$REMOTE_HOST" ]]; then
  echo "Usage: $0 user@remote-host [branch]"
  echo "Default branch: 4.0"
  exit 1
fi

# === Check local EYAML key files ===
if [[ ! -f "$PRIVATE_KEY_PATH" || ! -f "$PUBLIC_KEY_PATH" ]]; then
  echo "❌ Missing EYAML keys in current directory:"
  echo "  - $PRIVATE_KEY_PATH"
  echo "  - $PUBLIC_KEY_PATH"
  exit 1
fi

# === Step 1: Upload EYAML keys ===
log "🔐 Uploading EYAML keys to $REMOTE_HOST..."
scp "$PRIVATE_KEY_PATH" "$PUBLIC_KEY_PATH" "$REMOTE_HOST:/tmp/"

# === Step 2: One SSH session does everything else ===
log "🚀 Connecting to $REMOTE_HOST to set up and run bootstrap..."

ssh "$REMOTE_HOST" bash <<EOF
  set -e

  sudo mkdir -p  /etc/puppetlabs/facter/facts.d
  echo "packer_build=true" | sudo tee /etc/puppetlabs/facter/facts.d/packer.txt > /dev/null
  echo "[+] Creating EYAML key directory..."
  sudo mkdir -p "$REMOTE_KEY_DIR"

  echo "[+] Moving EYAML keys into place..."
  sudo mv /tmp/private_key.pkcs7.pem "$REMOTE_KEY_DIR/"
  sudo mv /tmp/public_key.pkcs7.pem "$REMOTE_KEY_DIR/"

  echo "[+] Setting key file ownership and permissions..."
  sudo chown -R root:root "$REMOTE_KEY_DIR"
  sudo chmod 700 "$REMOTE_KEY_DIR"

  sudo apt-get update

  # Install git if not installed
  if ! command -v git &> /dev/null; then
    echo "[+] installing git..."
    sudo apt-get install -y git
  fi

  # Install git-lfs if not installed
  if ! command -v git-lfs &> /dev/null; then
    echo "[+] installing git-lfs..."
    sudo apt-get install -y git-lfs
  fi

  echo "[+] Cloning virtual_appliance "$GITHUB_REPO_URL" ..."
  [[ -d "$VA" ]] && sudo rm -Rf $VA
  sudo git clone --branch "$BRANCH" --single-branch "${GITHUB_REPO_URL}" "$VA"

  echo "[+] Executing server_bootstrap_entrypoint.sh to install Puppet, provision infrastructure, and deploy app..."
  sudo bash "$REMOTE_BOOTSTRAP"

  echo "✅ Server bootstrapping complete."
EOF

log "✅ Bootstrap completed on $REMOTE_HOST (branch: $BRANCH)"

