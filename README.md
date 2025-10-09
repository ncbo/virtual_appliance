# OntoPortal Virtual Appliance ToolKit

The OntoPortal Virtual Appliance provides a ready-to-run environment for the full OntoPortal software stack, delivered as a virtual machine or cloud image. It lets you launch an OntoPortal instance quickly, while still giving you full control to customize and configure the system for production use.

This repository (virtual_appliance) contains the scripts and configuration needed to set up the underlying infrastructure (operating system, directory structure, and core services like Nginx, MySQL, and the triple store), deploy the OntoPortal components (API, UI, ncbo_cron, etc.), and manage updates for the appliance.

---

## Overview

**What it provides**
- Full BioPortal stack (UI, API, cron, Solr, triple store, MySQL, Redis, Tomcat, etc.) in a single VM  
- Works on VMware (OVF), AWS (AMI), or directly on Ubuntu 22.04 servers  
- Deployment scripts allow Capistrano-based deployments to be run locally on the appliance, rather than through GitHub workflows as in BioPortal production.

**What it is not**
- A simple “black box” VM  
- Updates are still complex and require careful use of the provided tools  

---

## Repository Layout

- **infra/**  
  Infrastructure provisioning scripts.
  - Installs Puppet on the target host, then uses it to apply the external configuration. The Puppet configuration (control repo and modules) is not included in this repository. During provisioning, the control repo is cloned and the required modules (including the OntoPortal module) are fetched and applied.
  - Example workflow: `remote_bootstrap_runner.sh` copies scripts to a host, then `server_bootstrap_entrypoint.sh` installs Puppet and applies the control repo.  

- **deployment/**  
  Application deployment scripts.  
  - `versions` – pins component versions (UI, API, cron, OLd, etc.) known to be compatible with this appliance release.  
     Versions are locked to match the appliance’s infrastructure (Ruby, Solr config, app server choice).  
  - `setup_deploy_env.sh` – fetches repos at pinned versions and prepares Capistrano scripts. Does not deploy.  
  - `deploy_ui.sh`, `deploy_api.sh` – run Capistrano to deploy application code and configs.  

- **appliance_config/**  
  Application config templates and overrides. Used by Capistrano to populate live directories.  
  Supports local customizations (logos, themes, small code tweaks).  
  Manual edits in live directories will be overwritten on redeploy.  

---

## Configuration

- **Global config**: `/opt/ontoportal/site_config.rb`  
  Defines hostnames, ports, org info, and API key (regenerated on first boot).  
  Uses `InfraDiscovery` to auto-detect hostname/IP in cloud environments.  
  Replace with static values if deploying with a fixed FQDN and TLS certs.  

- **Component config**: `appliance_config/<component>/`  
  Contains application-specific configs and override files.  
  Example:  `appliance_config/bioportal_web_ui/config/locales/en/appliance-overrides.yml`
  ```yaml
  en:
    home:
      index:
        tagline: your ontology repository for your ontologies
  ```

---

## Update Paths

- **Patch update** (e.g., 4.1.0 → 4.1.1):  
  ```bash
  cd virtual_appliance
  git pull
  ./deployment/setup_deploy_env.sh
  ./deployment/deploy_all.sh
  ```

- **Minor update** (e.g., 4.0 → 4.1):  
  - Switch to the new branch (`git checkout 4.1`)  
  - Review and update `appliance_config`  
  - Run Puppet to apply infrastructure provisioning changes (e.g., new Ruby or Solr version)  
  - Apply patch update workflow  

- **Major update**:  
  - May involve migrations or more extensive Puppet runs  
  - In-place upgrades are possible, but results vary for heavily customized appliances  

## References

- BioPortal: https://bioportal.bioontology.org  
- OntoPortal Alliance: https://ontoportal.org  
- OntoPortal Documentation: https://ontoportal.github.io/documentation  
- Virtual Appliance GitHub repo: https://github.com/ncbo/virtual_appliance  

---

## License

Maintained by the OntoPortal Alliance.  
AllegroGraph is a commercial product from Franz Inc. The appliance includes a limited license suitable for moderate deployments; OntoPortal Alliance members may request larger licenses.

