#!/bin/bash
set -euo pipefail

# --- Require sudo ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root or with sudo."
  echo "Try: sudo $(basename "$0")"
  exit 1
fi

# --- Description & Help ---
show_help() {
  cat <<EOF
OntoPortal SSL Certificate Generation Script
--------------------------------------------
This script is designed for use with OntoPortal virtual appliances.

It generates a self-signed SSL certificate with SANs (Subject Alternative Names)
to enable secure communication between the OntoPortal UI and API server.

💡 In production, it's recommended to install a valid certificate from a trusted
   Certificate Authority (e.g., Let's Encrypt, commercial CA).

Usage:
  $(basename "$0") [updatetruststore]

Options:
  updatetruststore    Add the generated certificate to the system trust store.
  --help              Show this help message.

Notes:
- Supports Debian-based and RedHat-based systems.
- Automatically includes hostname, IP, FQDN, and AWS public DNS (if detected).
- Must be run as root or with sudo.

EOF
  exit 0
}

# Handle --help flag
if [[ "${1:-}" == "--help" ]]; then
  show_help
fi


# --- OS Detection & Variable Setup ---
if [ -f /etc/debian_version ]; then
    OS="Debian"
    CERT_FILE="/etc/ssl/certs/ssl-cert-snakeoil.pem"
    KEY_FILE="/etc/ssl/private/ssl-cert-snakeoil.key"
    TRUST_STORE="/usr/local/share/ca-certificates/snakeoil.crt"
    UPDATE_TRUST_COMMAND="update-ca-certificates"
    CHOWN_COMMAND="chown root:ssl-cert"
elif [ -f /etc/redhat-release ]; then
    OS="RedHat"
    CERT_FILE="/etc/ssl/certs/localhost.crt"
    KEY_FILE="/etc/pki/tls/private/localhost.key"
    TRUST_STORE="/etc/pki/ca-trust/source/anchors/snakeoil.crt"
    UPDATE_TRUST_COMMAND="update-ca-trust extract"
    CHOWN_COMMAND=":" # No-op
else
    echo "❌ Unsupported OS. Only Debian-based or RedHat-based systems are supported."
    exit 1
fi

# --- Gather SAN Info ---
HOSTNAME=$(hostname)
FQDN=$(hostname -f)
IP=$(ip -4 route get 1.1.1.1 | awk '/src/ {print $7; exit}')
PTR_NAME=$(dig +short -x "$IP" | sed 's/\.$//')

# --- AWS Detection & Public Hostname ---
AWS_PUBLIC_DNS=""
if curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/ &>/dev/null; then
  AWS_PUBLIC_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname || true)
fi

ALT_NAMES_FILE=$(mktemp)
i=1
echo "DNS.${i} = localhost" >> "$ALT_NAMES_FILE"; ((i++))
[[ "$HOSTNAME" != "localhost" ]] && echo "DNS.${i} = ${HOSTNAME}" >> "$ALT_NAMES_FILE" && ((i++))
echo "DNS.${i} = ${FQDN}" >> "$ALT_NAMES_FILE"; ((i++))
echo "DNS.${i} = *.${FQDN#*.}" >> "$ALT_NAMES_FILE"; ((i++))
[[ -n "$PTR_NAME" ]] && echo "DNS.${i} = ${PTR_NAME}" >> "$ALT_NAMES_FILE" && ((i++))
[[ -n "$AWS_PUBLIC_DNS" ]] && echo "DNS.${i} = ${AWS_PUBLIC_DNS}" >> "$ALT_NAMES_FILE" && ((i++))
echo "IP.${i} = 127.0.0.1" >> "$ALT_NAMES_FILE"; ((i++))
echo "IP.${i} = ${IP}" >> "$ALT_NAMES_FILE"; ((i++))

# --- OpenSSL Config ---
OPENSSL_CONFIG=$(mktemp)
trap 'rm -f "$OPENSSL_CONFIG" "$ALT_NAMES_FILE"' EXIT

cat > "$OPENSSL_CONFIG" <<EOF
[req]
distinguished_name=req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN=localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
$(cat "$ALT_NAMES_FILE")
EOF

# --- Generate Certificate ---
openssl req -x509 -nodes -days 3650 \
  -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -config "$OPENSSL_CONFIG" \
  -extensions v3_req

chmod 640 "$KEY_FILE"
$CHOWN_COMMAND "$KEY_FILE"

echo "✅ Self-signed certificate with SANs created:"
openssl x509 -in "$CERT_FILE" -noout -text | grep -A 10 "Subject Alternative Name"

# --- Optionally Update Trust Store ---
if [[ "${1:-}" == "updatetruststore" ]]; then
  echo "🔄 Adding certificate to system trust store..."
  cp "$CERT_FILE" "$TRUST_STORE"
  if $UPDATE_TRUST_COMMAND; then
    echo "✅ Certificate successfully added to trust store."
  else
    echo "❌ Failed to update system trust store using '$UPDATE_TRUST_COMMAND'."
    exit 1
  fi
fi

