#!/bin/bash
# generate self-signed dummy tls certificate

# Detect the operating system
if [ -f /etc/debian_version ]; then
    OS="Debian"
elif [ -f /etc/redhat-release ]; then
    OS="RedHat"
else
    echo "Unsupported OS. Only Debian-based or RedHat-based systems are supported."
    exit 1
fi


if [ "$OS" == "RedHat" ]; then
FQDN=`hostname`
head /dev/urandom > /dev/null
openssl req -new -newkey rsa:2048 -rand /dev/urandom -nodes -x509 \
  -keyout /etc/pki/tls/private/localhost.key \
  -out /etc/ssl/certs/localhost.crt \
  -subj "/C=US/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationUnit/CN=${FQDN}"

chmod 600 /etc/pki/tls/private/localhost.key
chmod 600 /etc/ssl/certs/localhost.crt
fi

if [ "$OS" == "Debian" ]; then
  make-ssl-cert generate-default-snakeoil --force-overwrite
fi

echo "Created self-signed TLS certs"
