#!/bin/bash
# generate self-signed dummy tls certificate

FQDN=`hostname`
head /dev/urandom > /dev/null
openssl req -new -newkey rsa:2048 -rand /dev/urandom -nodes -x509 \
  -keyout /etc/pki/tls/private/localhost.key \
  -out /etc/ssl/certs/localhost.crt \
  -subj "/C=US/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationUnit/CN=${FQDN}"

chmod 600 /etc/pki/tls/private/localhost.key
chmod 600 /etc/ssl/certs/localhost.crt
