#!/bin/bash
# Script for cleaning up files used for packaging appliance
# DO NOT RUN

#cleaning log files
TOMCAT=/usr/share/tomcat
MYSQL=/var/lib/mysql
RUBYBNDL=2.5.0

standard(){
/usr/local/bin/opstop
yum clean all
cd /var/log
>/var/log/messages
find . -type f -delete
/bin/rm -Rf /tmp/*
/bin/rm /root/.mysql_history
/bin/rm $MYSQL/*.pid
/bin/rm $MYSQL/*.err
/bin/rm $MYSQL/ib_logfile*

/bin/rm -Rf $TOMCAT/temp/*
/bin/rm -Rf $TOMCAT/work/*
/bin/rm /srv/redis/goo_cache/*
/bin/rm /srv/redis/http_cache/*
/bin/rm /srv/ncbo/ncbo_cron/logs/*
/bin/rm /srv/solr/logs/*
}

extra(){
/bin/rm -f /root/anaconda-ks.cfg
/bin/rm /var/spool/mail/*
/bin/rm -Rf /root/.ssh
/bin/rm /root/.bash_history
/bin/rm -Rf /root/install
/bin/rm -Rf /root/.gem
/bin/rm -Rf /etc/ssh/ssh_host_*
/bin/rm /var/lib/logrotate.status
/bin/rm /etc/resolv.conf
/bin/rm /etc/udev/rules.d/70-persistent-net.rules
/bin/rm -Rf /home/ec2-user/.ssh/*
/bin/rm -Rf /tmp/*
/bin/rm -Rf /root/tmp
yum remove -y 'puppet*'
rpm -e ruby-augeas
rpm -e facter
#rpm -e augeas-libs
/bin/rm -Rf /var/lib/puppet/
/bin/rm -Rf /etc/puppetlabs
/bin/rm /home/ontoportal/.ruby-uuid
/bin/rm -Rf /home/ontoportal/.pki
/bin/rm -Rf /home/ontoportal/.passenger
/bin/rm /etc/yum.repos.d/bmir.repo
/bin/rm /var/lib/dhclient/*
/bin/rm -Rf /opt/solr_downloads

#remove old kernels
package-cleanup -y --oldkernels --count=1
runuser -l ontoportal -c  'gem cleanup'

#ruby gem caches
rm -Rf /srv/rails/bioportal_web_ui/shared/bundle/ruby/$RUBYBNDL/cache/*
rm -Rf /srv/ncbo/ncbo_cron/vendor/bundle/ruby/$RUBYBNDL/cache/*
rm -Rf /srv/ncbo/ontologies_api/shared/bundle/ruby/$RUBYBNDL/cache/*


rm /srv/redis/dump.rdb

# Remove deployment related directories; those can be re-created during deploymnet
rm -Rf /srv/ncbo/virtual_appliance/deployment/bioportal_web_ui
rm -Rf /srv/ncbo/virtual_appliance/deployment/ontologies_api
rm -Rf /srv/ncbo/virtual_appliance/appliance_config/ontologies_linked_data
#remove SSH host keys (or perhaps sys-unconfig takes care of it)
yum clean all
}

hist(){
for i in .viminfo .mysql_history .bash_history .rediscli_history .pry_history .ssh/known_host .bundle/cache .gitconfig .rbenv
do
  shred -u /root/$i
  shred -u /home/ec2-user/$i
  shred -u /home/ontoportal/$i
  shred -u /srv/4store/$i
done

history -c
}

swap(){
swapoff -a
dd if=/dev/zero of=/dev/mapper/vg_sys-lv_swap bs=102400
mkswap /dev/mapper/vg_sys-lv_swap
}

shrink(){
dd if=/dev/zero of=/tmp/delme bs=102400 || rm -rf /tmp/delme
}
unconfig(){
# remove mac address
sed -i -e '/HWADDR/c\' /etc/sysconfig/network-scripts/ifcfg-e*
# reset ontoportal instance id
/bin/systemctl start redis-server-presistant.service
sleep 1
redis-cli del ontoportal.instance.id
touch /srv/ncbo/firstboot
chown ontoportal:ontoportal /srv/ncbo/firstboot
chage -d 0 root
: > /etc/machine-id
history -c

#sys-unconfig

}

if [ "$1" = "nukeit" ]; then
  unset HISTFILE
  standard
  extra
  swap
  hist
  shrink
  unconfig
fi
