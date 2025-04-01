# Changelog

## [4.0.0.a2] - 2025-03-31

- Improved self-signed TLS certificate generation  
- Improved robustness of provisioning scripts  
- changed the default ssh login account to `ubuntu`
- enabled API throtteling by default
- **OntoPortal Stack Changes:**
  - `ontologies_api` [v6.0.0](https://github.com/ncbo/ontologies_api/releases/tag/v6.0.0)
  - `ncbo_cron` [v6.0.0](https://github.com/ncbo/ncbo_cron/releases/tag/v6.0.0)
  - `bioportal_web_ui` [v7.4.0](https://github.com/ncbo/bioportal_web_ui/releases/tag/v7.4.0)

---

## [4.0.0.a1] - 2025-03-20

- Replaced CentOS 7 with Ubuntu 22.04
- Replaced Apache/mod_passenger with Nginx/Puma
- HTTPS is now the default for both UI and API
- Application files reside under `/opt/ontoportal`; data is stored under `/srv/ontoportal`
- Added infrastructure provisioning scripts including puppet
- Default SSH login username changed from `centos` to `opadmin`
- `hostname_lookup` script now includes reverse DNS (PTR) lookup for hostname/FQDN
- **OntoPortal Stack Changes:**
  - Ruby 3.1
  - Node.js 20 (required for Yarn)
  - HTTPS is now default for both UI and API with self-signed SSL certificates
  - Solr v8.11.3
  - Tomcat 9.0.102
  - `ontologies_api` [v5.33.5](https://github.com/ncbo/ontologies_api/releases/tag/v5.33.5)  
  - `ncbo_cron` [v5.33.5](https://github.com/ncbo/ncbo_cron/releases/tag/v5.33.5)  
  - `bioportal_web_ui` [v7.3.2](https://github.com/ncbo/bioportal_web_ui/releases/tag/v7.3.2)

---

## [3.2.2] - 2023-10-15
- Ontoportal Stack Changes:
  - nodejs v16
  - certbot is installed by default
  - ontologies_api [v5.26.2](https://github.com/ncbo/ontologies_api/releases/tag/v5.26.2)
  - ncbo_cron [v5.26.2](https://github.com/ncbo/ncbo_cron/releases/tag/v5.26.2)
## [3.2.1] - 2023-09-24
- Disable deprecated ssh cyphers and kexalgorithms to make vulnerability
  scanners happier
- improve robustness of the firstboot and hostname_lookup scripts
- Ontoportal Stack Changes:
  - tomcat v9.0.92
  - ontologies_api [v5.26.1](https://github.com/ncbo/ontologies_api/releases/tag/v5.26.1)
  - ncbo_cron [v5.26.0](https://github.com/ncbo/ncbo_cron/releases/tag/v5.26.0)
## [3.2.0] - 2023-07-26
- OntoPortal Stack Changes:
  - tomcat v9.0.78
  - ruby v2.7.8
  - solr v8.11.2
  - ontologies_api [v5.25.0](https://github.com/ncbo/ontologies_api/releases/tag/v5.25.0)
  - ncbo_cron [v5.25.0](https://github.com/ncbo/ncbo_cron/releases/tag/v5.25.0)
  - bioportal_web_ui [v6.11.0](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.11.0)
## [3.1.1] - 2022-06-02
- OntoPortal Stack Changes:
  - tomcat v9.0.63
  - Disable TLS 1 and weak ciphers in apache and nginx
## [3.1.0] - 2022-05-10
- OntoPortal Stack Changes:
  - bioportal_web_ui [v6.7.1](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.7.1)
  - ontologies_api/ncbo_cron v5.22.3
  - ruby v2.7.6
  - tomcat v9.0.62 installed from source
  - redis instances are renamed goo -> goo_cache and http -> http_cache
## [3.0.6] - 2022-01-07
- Addressed log4j/log4shell CVE-2021-44228 vulnerability
- OntoPortal Stack Changes:
  - bioportal_web_ui [v6.5.1](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.5.1)
  - ontologies_api/ncbo_cron v5.22.1
  - solr upgraded to 8.11.1
  - ruby 2.6.9
  - annotatorplus
  - https is enabled in nginx for the api on port 8443.
- Known Issues:
  - deployment of proper TLS/SSL certificates is required for the full enablement of HTTPS
## [3.0.5] - 2021-09-24
- AllegroGraph is removed because it is not fully supported at this time. This
    reduced the size of OVF down to 1.7Gb
- OntoPortal Stack Changes:
  - bioportal_web_ui [v6.5.0](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.5.0)
- Known Issues:
  - OntoPortal footer displays incorrect version of the appliance.
## [3.0.4] - 2021-07-07
- OntoPortal Stack Changes:
  - bioportal_web_ui [v6.4.0](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.4.0)
  - ontologies_api/ncbo_cron v5.22.0
  - solr upgraded to 8.8.2
  - ruby 2.6.7
  - https is enabled in Apache/Web_UI using self-signed certificates.
- Fixed:
  - [yum update process breaks apache](https://github.com/ncbo/virtual_appliance/issues/20)
## [3.0.3] - 2020-12-09
- Updated AlegroGraph to v7.0.4 RC3 to address goo compatibility issues.
- OntoPortal Stack Changes:
  - bioportal_web_ui [v6.2.0](https://github.com/ncbo/bioportal_web_ui/releases/tag/v6.2.0)
  - ontologies_api/ncbo_cron v5.19.0
  - Ruby on Rails v5.2
  - CentOS 7.9
## [3.0.2] - 2020-08-07
- OntoPortal Web UI displays a maintenance page until firstboot process is completed.
- OntoPortal Stack Changes:
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
  - AllegroGraph v6.4.1 is installed but not activated.
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

