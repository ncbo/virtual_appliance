#Script for deploying biomixer war file to tomcat
#

source "$(dirname "$0")/config.sh"

cp $VIRTUAL_APPLIANCE_REPO/deployment/artifacts/annotatorplus.war /srv/tomcat/webapps
