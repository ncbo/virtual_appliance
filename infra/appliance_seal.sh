#!/bin/bash
# Script for cleaning up files when packaging appliance
# DO NOT RUN

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Exiting." >&2
  exit 1
fi

if [[ "$1" != "nukeit" ]]; then
  echo "not gonna do it just like that"
  exit 1
fi

#set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

TOMCAT=/usr/share/tomcat
MYSQL=/var/lib/mysql
RUBYBNDL=3.1.0
APP_DIR=/opt/ontoportal
DATA_DIR=/srv/ontoportal/data


echo "[*] Sealing appliance before export..."
/usr/local/bin/opctl stop

# Remove persistent udev rules
echo "[*] Removing udev persistent net rules..."
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# Remove tmp files
echo "[*] Removing temporary files..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clear cloud-init cache
if [ -d /var/lib/cloud ]; then
    echo "[*] Removing cloud-init data..."
    cloud-init clean --logs
    rm -rf /var/lib/cloud/*
fi

# Remove machine-id (will regenerate on boot)
echo "[*] Cleaning machine-id..."
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id

# Remove user SSH keys and known hosts
echo "[*] Cleaning user SSH keys..."
find /home -name 'id_rsa*' -exec rm -f {} \;
find /home -name 'known_hosts' -exec rm -f {} \;

logs(){
  systemctl stop systemd-journald || true

  # Remove all app logs
  /bin/rm ${APP_DIR}/ncbo_cron/logs/*
  /bin/rm ${APP_DIR}/bioportal_web_ui/shared/log/*
  /bin/rm ${APP_DIR}/ontologies_api/shared/log/*
  /bin/rm ${DATA_DIR}/solr/logs/*
  /bin/rm ${APP_DIR}/bioportal_web_ui/shared/log/*

  # Remove all system logs aggressively
  echo "[*] Deleting all log files..."
  find /var/log -type f -delete

  # Clean journal logs
  rm -rf /var/log/journal
}

apt_cleanup() {

  # List of packages to purge
  PURGE_PACKAGES=(

    linux-firmware

    # Storage-related
    multipath-tools
    mdadm
    btrfs-progs
    nfs-common
    open-iscsi

    # GUI and fonts
    snapd
    x11-common
    xkb-data
    fonts-dejavu-core
    fonts-ubuntu

    # Documentation and dev tools
    manpages
    man-db
    info
    groff-base
    doc-base
    installation-report

    # Crash reporting / telemetry
    apport
    whoopsie
    popularity-contest
    friendly-recovery
    plymouth

    # Network/Remote daemons (optional)
    avahi-daemon

  )
  apt-get update
  apt-get upgrade -y

  # purge linux-headers
  dpkg -l 'linux-headers-*' | awk '/^ii/{print $2}' | xargs apt-get purge -y

  apt-get purge -y "${PURGE_PACKAGES[@]}" || true

  apt-get autoremove --purge -y
  apt-get clean

  # Not usually needed, but here if you're cleaning aggressively:
  rm -rf /var/lib/apt/lists/*
}

standard(){

  userdel -r packer
  userdel -r vagrant
  userdel -r ansible

  /bin/rm /root/.mysql_history
  /bin/rm $MYSQL/*.pid
  /bin/rm $MYSQL/*.err

  /bin/rm -Rf $TOMCAT/temp/*
  /bin/rm -Rf $TOMCAT/work/*
  /bin/rm ${APP_DIR}/ncbo_cron/logs/*
  /bin/rm ${APP_DIR}/bioportal_web_ui/shared/log/*
  /bin/rm ${APP_DIR}/ontologies_api/shared/log/*
  /bin/rm ${DATA_DIR}/solr/logs/*
  /bin/rm ${APP_DIR}/bioportal_web_ui/shared/log/*

  /bin/rm /root/original-ks.cfg
  /bin/rm /root/ks-p*.log
  /bin/rm /root/install.sh
}

extra(){
  /bin/rm /var/spool/mail/*
  /bin/rm -Rf /root/.ssh
  /bin/rm /var/lib/logrotate/status
  /bin/rm -Rf /root/tmp
  /bin/rm -Rf /root/.gem
  /bin/rm -Rf /root/.r10k
  /bin/rm -Rf /root/.cache


  /bin/rm /home/op-admin/.ruby-uuid
  /bin/rm -Rf /home/op-admin/.pki
  /bin/rm -Rf /home/op-admin/.cache
  /bin/rm -Rf /home/op-admin/.bundle/.cache
  /bin/rm -Rf /home/op-admin/.local
  /bin/rm -Rf /home/op-admin/.yarn
  /bin/rm -Rf /opt/staging
  /bin/rm -Rf /opt/solr_downloads
  #/bin/rm -Rf /usr/local/src/4store/.git

  #pushd ${APP_DIR}/virtual_appliance/deployment/bioportal_web_ui
  #bundle exec cap appliance bundler:cleanup
  #popd
  #pushd ${APP_DIR}/virtual_appliance/deployment/ontologies_api
  #bundle exec cap appliance bundler:cleanup
  #popd

  #ruby gem caches
  #rm -Rf ${APP_DIR}/bioportal_web_ui/shared/bundle/ruby/$RUBYBNDL/cache/*
  #rm -Rf ${APP_DIR}/ncbo_cron/vendor/bundle/ruby/$RUBYBNDL/cache/*
  #rm -Rf ${APP_DIR}/ontologies_api/shared/bundle/ruby/$RUBYBNDL/cache/*
  rm -Rf ${APP_DIR}/.bundle/ruby/$RUBYBNDL/cache/*

  rm -Rf ${APP_DIR}/bioportal_web_ui/repo
  rm -Rf ${APP_DIR}/ontologies_api/repo

  # Remove deployment related directories; those can be re-created during deploymnet
  rm -Rf ${APP_DIR}/virtual_appliance/deployment/bioportal_web_ui
  rm -Rf ${APP_DIR}/virtual_appliance/deployment/ontologies_api
  rm -Rf ${APP_DIR}/virtual_appliance/appliance_config/ontologies_linked_data

}

hist(){
  for i in .cache .viminfo .mysql_history .bash_history .rediscli_history .pry_history .ssh/known_host .bundle/cache .gitconfig .rbenv .ssh/authorized_keys
  do
    shred -u /root/$i
    shred -u /home/ubuntu/$i
    shred -u /home/op-admin/$i
  done

  history -c
}

swap(){
  swapoff -a
  swapon -a
}

shrink(){
  dd if=/dev/zero of=/delme bs=102400 || rm -rf /delme
  sync
}

unconfig(){

# Remove SSH host keys (to be regenerated on boot)
echo "[*] Removing SSH host keys..."
rm -f /etc/ssh/ssh_host_*

# reset ontoportal instance id
/bin/systemctl start redis-server-persistent.service
sleep 1

# resetting appliance id perhaps should be done in the firtboot as well.
redis-cli del ontoportal.instance.id
/bin/systemctl stop redis-server-persistent.service
touch ${APP_DIR}/config/firstboot
#remove puppet fact that we need for packer builds only
rm /etc/puppetlabs/facter/facts.d/packer.txt
chown ontoportal:ontoportal ${APP_DIR}/firstboot
history -c
/usr/local/bin/opctl stop
sleep 10

#sys-unconfig

}

  echo "====>> Sealing Appliance"
  unset HISTFILE
  standard
  extra
  apt_cleanup
  hist
  unconfig
  logs
  shrink

  # debugging
  who
  ps -ef
  cat /etc/passwd

  # Make sure we wait until all the data is written to disk, otherwise
  # Packer might quit too early before the large files are deleted
  sync

  echo "====>> Done sealing appliance"

