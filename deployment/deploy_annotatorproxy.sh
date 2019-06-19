#Script for deploying biomixer war file to tomcat
#

source $(dirname "$0")/versions

cp $VIRTUAL_APPLIANCE_REPO/deployment/artifacts/annotatorplus.war /usr/share/tomcat/webapps
