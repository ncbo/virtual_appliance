#!/bin/bash
# Script to reset BioPortal admin password to the AMI instance ID
INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
APIKEY='1cfae05f-9e67-486f-820b-b393dec5764b'
echo setting BioPortal Admin user password to $INSTANCEID
curl -XPATCH http://localhost:8080/users/admin\?apikey\="$APIKEY" -d "password=$INSTANCEID
