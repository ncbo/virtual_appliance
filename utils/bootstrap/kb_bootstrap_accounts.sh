#!/bin/bash
# 4Store KB bootstrap script to create initial OntoPortal user/service accounts

cd /srv/ncbo/ncbo_cron
bundle exec rake user:create['admin','admin@nodomain.org','changemeNOW']
bundle exec rake user:adminify['admin']
bundle exec rake user:create['ontoportal_ui','ontoportal_ui@nodomain.org']
