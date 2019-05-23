#Script for deploying biomixer war file to tomcat
#

source $(dirname "$0")/versions

cp $VIRTUAL_APPLIANCE_REPO/deployment/artifacts/biomixer.war /usr/share/tomcat/webapps
<<<<<<< HEAD
=======
#sudo systemctl restart tomcat
>>>>>>> 1ef2bc895dd8328e01078c62e57c27dbbc50bf6d
