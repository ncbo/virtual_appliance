#!/bin/bash
# Create AG repostiory and user for ontoportal

CREDS='super:super'
curl -u${CREDS} -X PUT 'http://localhost:10035/repositories/ontoportal'
curl -u${CREDS} -X PUT 'http://localhost:10035/repositories/ontoportal/suppressDuplicates'
curl -u${CREDS} -X PUT 'http://localhost:10035/users/anonymous'
curl -u${CREDS} -X PUT 'http://localhost:10035/users/anonymous/access?read=true&write=true&repositories=ontoportal'
curl -u${CREDS} -X GET 'http://localhost:10035/repositories'
