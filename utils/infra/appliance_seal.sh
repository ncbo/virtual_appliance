#!/bin/bash
# Script for cleaning up files when packaging appliance
# DO NOT RUN


if [ "$1" != "nukeit" ]; then
  echo "not gonna do it just like that"
  exit 1
fi

#set -euo pipefail

TOMCAT=/usr/share/tomcat
MYSQL=/var/lib/mysql
RUBYBNDL=3.1.0
APP_DIR=/opt/ontoportal
DATA_DIR=/srv/ontoportal/data


echo "[*] Sealing appliance before export..."
/usr/local/bin/opstop

# Remove persistent udev rules
echo "[*] Removing udev persistent net rules..."
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# Remove SSH host keys (to be regenerated on boot)
echo "[*] Removing SSH host keys..."
rm -f /etc/ssh/ssh_host_*

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

apt(){
  # remove useless packages
  apt remove samba-common

  #clean apt
  apt-get clean
  apt-get autoremove -y

  sudo rm -rf /var/lib/apt/lists/*
}

standard(){
  userdel -R packer
  userdel -R vagrant 
  userdel -R ansible

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
  /bin/rm /etc/resolv.conf
  /bin/rm -Rf /home/ec2-user/.ssh/*
  /bin/rm -Rf /root/tmp

  /bin/rm /home/ontoportal/.ruby-uuid
  /bin/rm -Rf /home/ontoportal/.pki
  /bin/rm -Rf /home/ontoportal/.cache
  /bin/rm -Rf /home/ontoportal/.bundle/.cache
  /bin/rm -Rf /home/ontoportal/.local
  /bin/rm -Rf /home/ontoportal/.yarn
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
    shred -u /home/admin/$i
    shred -u /home/ec2-user/$i
    shred -u /home/ontoportal/$i
  done

  history -c
}

swap(){
  swapoff -a
  swapon -a
  #dd if=/dev/zero of=/dev/mapper/centos-swap bs=102400
  #mkswap  /dev/mapper/centos-swap
}

shrink(){
  dd if=/dev/zero of=/tmp/delme bs=102400 || rm -rf /tmp/delme
  sync
}

unconfig(){
# reset ontoportal instance id
/bin/systemctl start redis-server-persistent.service
sleep 1

# resetting appliance id perhaps should be done in the firtboot as well.
redis-cli del ontoportal.instance.id
/bin/systemctl stop redis-server-persistent.service
touch ${APP_DIR}/firstboot
chown ontoportal:ontoportal ${APP_DIR}/firstboot
history -c
/usr/local/bin/opstop
sleep 10

#sys-unconfig

}

  echo "====>> Sealing Appliance"
  unset HISTFILE
  standard
  apt
  extra
  hist
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


