#!/bin/bash
# Script for cleaning up files used for packaging appliance
# DO NOT RUN

if "$1" != 'cleanit'
  echo 'this script is not intended to be run'
  exit 1
fi

#cleaning log files
TOMCAT=/usr/share/tomcat6
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
yum remove puppet* 
rpm -e ruby-augeas
rpm -e facter
yum remove puppet* 
#rpm -e augeas-libs
/bin/rm -Rf /var/lib/puppet/
/bin/rm -Rf /etc/puppet
/bin/rm /home/ontoportal/.ruby-uuid
#/bin/rm -Rf /var/lib/ncbobp/.gem
/bin/rm -Rf /home/ontoportal/.pki
/bin/rm -Rf /home/ontoportal/.passenger
/bin/rm /etc/yum.repos.d/bmir.repo 
/bin/rm /var/lib/dhclient/*
/bin/rm -Rf /opt/solr_downloads

#remove old kernels
package-cleanup --oldkernels --count=1
runuser -l ontoportal -c  'gem cleanup'

#ruby gem caches
rm -Rf /srv/rails/bioportal_web_ui/shared/bundle/ruby/$RUBYBNDL/cache/*
rm -Rf /srv/ncbo/ncbo_cron/vendor/bundle/ruby/$RUBYBNDL/cache/*
rm -Rf /srv/ncbo/ontologies_api/shared/bundle/ruby/$RUBYBNDL/cache/*


rm /srv/redis/dump.rdb

#rm -Rf /home/ontoportal/virtual_appliance/appliance_config
#rm -Rf /home/ontoportal/virtual_appliance/deployment/bioportal_web_ui
#rm -Rf /home/ontoportal/virtual_appliance/deployment/ontologies_api
#remove SSH host keys (or does sys-unconfig takes care of it)
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
dd if=/dev/zero of=/dev/mapper/vg_sys-lv_swap
mkswap dev/mapper/vg_sys-lv_swap 
}

shrink(){
dd if=/dev/zero of=/tmp/delme bs=102400 || rm -rf /tmp/delme
}
unconfig(){
redis-cli del ontoportal.instance.id
touch /root/firstboot
sys-unconfig
}

if [ "$1" = "nukeit" ]; then
  #standard
  #extra
  #swap
  #hist
  #shrink
  #unconfig
fi
