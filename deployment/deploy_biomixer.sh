#!/usr/bin/env bash
#
# OntoPortal Appliance deployment script for biomixer
#

source "$(dirname "$0")/versions"

cp $VIRTUAL_APPLIANCE_REPO/deployment/artifacts/biomixer.war /srv/tomcat/webapps
