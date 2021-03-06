#!/bin/bash
# Create 4store KB for ontologies api with 4 segments

echo "---> Create 4store KB"
/usr/local/bin/4s-admin delete-stores ontologies_api
/usr/local/bin/4s-admin create-store --segments=4 ontologies_api
/usr/local/bin/4s-admin start-stores ontologies_api
/usr/local/bin/4s-admin list-stores
echo "---> DONE creating 4store KB"
