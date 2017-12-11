#!/bin/bash
ncpath='/var/www/html'
ncdatapath='/host/nextcloud'
htuser='www-data'
htgroup='www-data'
rootuser='root'

printf "Creating possible missing Directories\n"
mkdir -p $ncpath/assets
mkdir -p $ncpath/updater

printf "chmod Files and Directories\n"
find ${ncpath}/ -type f -print0 | xargs -0 chmod 0640
find ${ncpath}/ -type d -print0 | xargs -0 chmod 0750

printf "chown Directories\n"
chown -R ${rootuser}:${htgroup} ${ncpath}
chown -R ${htuser}:${htgroup} ${ncpath}/apps/
chown -R ${htuser}:${htgroup} ${ncpath}/assets/
chown -R ${htuser}:${htgroup} ${ncpath}/themes/
chown -R ${htuser}:${htgroup} ${ncpath}/updater/

if [ ! -f /host/nextcloud/firstrun ]; then
  # New installation, run the setup
  printf "Creating possible missing Directories\n"
  mkdir -p $ncdatapath/data/log
  mkdir -p $ncdatapath/apps2
  mkdir -p $ncdatapath/config
  find ${ncdatapath}/ -type f -print0 | xargs -0 chmod 0640
  find ${ncdatapath}/ -type d -print0 | xargs -0 chmod 0750
  chown -R ${rootuser}:${htgroup} ${ncdatapath}
  chown -R ${htuser}:${htgroup} ${ncdatapath}/config/
  chown -R ${htuser}:${htgroup} ${ncdatapath}/data/
  chown -R ${htuser}:${htgroup} ${ncdatapath}/apps2
fi

chmod +x ${ncpath}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${ncpath}/.htaccess ]
 then
  chmod 0644 ${ncpath}/.htaccess
  chown ${rootuser}:${htgroup} ${ncpath}/.htaccess
fi
if [ -f ${ncdatapath}/data/.htaccess ]
 then
  chmod 0644 ${ncdatapath}/data/.htaccess
  chown ${rootuser}:${htgroup} ${ncdatapath}/data/.htaccess
fi
