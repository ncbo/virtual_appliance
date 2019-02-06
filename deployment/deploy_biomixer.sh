#Script for deploying biomixer war file to tomcat
#

source $(dirname "$0")/versions

sudo cp $VIRTUAL_APPLIANCE_REPO/deployment/artifacts/biomixer.war /usr/share/tomcat/webapps
#sudo systemctl restart tomcat
