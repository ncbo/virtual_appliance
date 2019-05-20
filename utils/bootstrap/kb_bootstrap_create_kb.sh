#!/bin/bash
# Create 4store KB for ontologies api with 4 segments

4s-admin delete-stores ontologies_api
4s-admin create-store --segments=4 ontologies_api
4s-admin start-stores ontologies_api
