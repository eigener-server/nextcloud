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
find ${ncpath} ! -user ${rootuser} -print0 | xargs -0 chown ${rootuser}:${htgroup}
find ${ncpath}/apps/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath}/assets/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath}/themes/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath}/updater/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath} ! -group ${htgroup} -print0 | xargs -0 chown ${rootuser}:${htgroup}
find ${ncpath}/apps/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath}/assets/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath}/themes/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}
find ${ncpath}/updater/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}

if [ ! -f /host/nextcloud/firstrun ]; then
  # New installation, run the setup
  printf "Creating possible missing Directories\n"
  mkdir -p $ncdatapath/data/log
  mkdir -p $ncdatapath/apps2
  mkdir -p $ncdatapath/config
  find ${ncdatapath}/ -type f -print0 | xargs -0 chmod 0640
  find ${ncdatapath}/ -type d -print0 | xargs -0 chmod 0750

  find ${ncdatapath} ! -user ${rootuser} -print0 | xargs -0 chown ${rootuser}:${htgroup}
  find ${ncdatapath}/config/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
  find ${ncdatapath}/data/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
  find ${ncdatapath}/apps2/ ! -user ${htuser} -print0 | xargs -0 chown ${htuser}:${htgroup}
  find ${ncdatapath} ! -group ${htgroup} -print0 | xargs -0 chown ${rootuser}:${htgroup}
  find ${ncdatapath}/config/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}
  find ${ncdatapath}/data/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}
  find ${ncdatapath}/apps2/ ! -group ${htgroup} -print0 | xargs -0 chown ${htuser}:${htgroup}
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
