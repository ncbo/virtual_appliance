# Changelog

## [3.0.3] - 2020-12-09
- Updated AlegroGraph to v7.0.4 RC3 to address goo compatibility issues.
- Ontoportal Stack Changes:
  - bioportal_web_ui [v6.2.0](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.2.0)
  - ontologies_api/ncbo_cron v5.19.0
  - Ruby on Rails v5.2
  - CentOS 7.9
## [3.0.2] - 2020-08-07
- Ontoportal Web UI displays a maintenance page until firstboot process is completed.
- Ontoportal Stack Changes:
  - bioportal_web_ui [v5.9.5](https://github.com/ncbo/bioportal_web_ui/releases/tag/v5.9.5)
  - ontologies_api/ncbo_cron v5.18.1
  - nginx downgraded to v1.16 which is included in epel yum repo
  - ruby 2.6.6
- Fixed:
  - unable to yum update [#17](https://github.com/ncbo/virtual_appliance/issues/17)
  - firstboot script fail on AWS [#18](https://github.com/ncbo/virtual_appliance/issues/18)
## [3.0.1] - 2020-05-06
- Application Stack updates:
 - CentOS upgraded to 7.9
 - disable root passwod.  Users have to use centos user login for SSH access.
- Fixed:
  - https://github.com/ncbo/virtual_appliance/issues/16

## [3.0.0] - 2020-04-24
- Packaging:
  - appliance packaging is fully automated with packer, puppet, deployment and bootstrap scripts. 
- OS Changes for VMWare ova package:
  - CentOS 6 is upgraded to CentOS 7.7
  - console based firstboot configuration is removed.  
  - eth0 is configured to do DHCP by default
  - root is required to change initial password on first login
- Application Stack changes:
  - Apache, MariaDB, memcached, tomcat, redis are installed from EPEL repo
  - Nginx updated to 1.17
  - Solr updated to 8.2
  - Java 11
  - ruby 2.5.7
  - Allegro Graph v6.4.1 is installed but not activated.
  - Directory structure is changed:
    - bioportal_web_ui is movded from /srv/rails/bioportal_web_ui to /srv/ontoportal/bioportal_web_ui
    - ontologies_api is moved from /srv/ncbo/ontologies_api to /srv/ontoportal/ontologies_api
    - ncbo_cron is moved from /srv/ncbo/ncbo_cron to /srv/ontoportal/ncbo_cron
    - virtual_appliance which includes deployment, configs and utilities are moved to /srv/ontoportal/virtual_appliance
    - application data lives in /srv/ontoportal/data.  One option for expanding storage would be to mount a new disk there after coping all data
- Ontoportal Stack changes:
  - bioportal_web_ui v5.9.3
  - ontologies_api and ncbo_cron v5.16.0
  - biomixer is updated to support https
  - new: annotatorplus proxy
- Appliance includes deployment scripts for performing limited minor and patch version updates of Ontoportal application components.
- Appliance customization process is changed:
   - /srv/ontoportal/virtual_appliance/appliance_config/site_config.rb for setting basic customization such as hostname, Site Name and Organzation. 
   - /srv/ontoportal/virtual_appliance/appliance_config/<component> customization and overwrites for ontoportal components such as UI and API
   - /srv/ontoportal/virtual_appliance/appliance_config/deployments contains application deployment scripts
 - experimental support for AllegroGraph
 - Updated Ontoportal branding

