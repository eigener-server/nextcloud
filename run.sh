#!/bin/sh

#set -e 


if [ ! -f /firstrun ]; then

    echo -e "\n" > /tmp/wait_for_mysql.php
    sed -i -e '$a<?php' \
           -e '$a\$connected = false;' \
           -e '$awhile(!\$connected) {' \
           -e '$a    try{' \
           -e '$a        \$dbh = new pdo(' \
           -e '$a            "mysql:host=mysql;dbname='${NEXTCLOUD_DB_NAME}'", "'${NEXTCLOUD_DB_USER}'", "'${NEXTCLOUD_DB_PASSWORD}'",' \
           -e '$a            array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)' \
           -e '$a        );' \
           -e '$a        \$connected = true;' \
           -e '$a    }' \
           -e '$a    catch(PDOException \$ex){' \
           -e '$a        error_log("Could not connect to MySQL");' \
           -e '$a        error_log(\$ex->getMessage());' \
           -e '$a        error_log("Waiting for MySQL Connection.");' \
           -e '$a        sleep(5);' \
           -e '$a    }' \
           -e '$a}' \
           -e '$a?>' \
    /tmp/wait_for_mysql.php

    if [ -f /host/nextcloud/firstrun ]; then
        # link the config to the app
        ln -sf /host/nextcloud/config/config.php /var/www/html/config/config.php &>/dev/null
    fi

    # Don't run this again
    touch /firstrun
fi

/usr/local/bin/php /tmp/wait_for_mysql.php


if [ ! -f /host/nextcloud/firstrun ]; then
    # New installation, run the setup
    mkdir -p /host/nextcloud/data/log
    mkdir -p /host/nextcloud/apps2
    mkdir -p /host/nextcloud/data
    mkdir -p /host/nextcloud/config

    chown -R www-data:www-data /var/www/html
    chown -R www-data:www-data /host/nextcloud/apps2
    chown -R www-data:www-data /host/nextcloud/data
    chown www-data:www-data /host/nextcloud/config

    echo -e "\n" >> /host/nextcloud/config/config.php
    instanceid=oc$(echo $PRIMARY_HOSTNAME | sha1sum | fold -w 10 | head -n 1)
    sed -i -e '$a<?php' \
           -e '$a\$CONFIG = array (' \
           -e '$a  "apps_paths" => array (' \
           -e '$a      0 => array (' \
           -e '$a              "path"     => "/var/www/html/apps",' \
           -e '$a              "url"      => "/apps",' \
           -e '$a              "writable" => false,' \
           -e '$a      ),' \
           -e '$a      1 => array (' \
           -e '$a              "path"     => "/host/nextcloud/apps2",' \
           -e '$a              "url"      => "/apps2",' \
           -e '$a              "writable" => true,' \
           -e '$a      ),' \
           -e '$a  ),' \
           -e '$a  "datadirectory" => "/host/nextcloud/data",' \
           -e '$a  #"memcache.local" => "\\OC\\Memcache\\APCu",' \
           -e '$a  "memcache.local" => "\\OC\\Memcache\\Redis",' \
           -e '$a  "filelocking.enabled" => "true",' \
           -e '$a   "redis" => array(' \
           -e '$a        "host" => "redis",' \
           -e '$a        "port" => 6379,' \
           -e '$a         ),' \
           -e '$a  "instanceid" => "'${instanceid}'",' \
           -e '$a  "trusted_domains" =>' \
           -e '$a    array (' \
           -e '$a      0 => "'${NEXTCLOUD_DOMAIN}'",' \
           -e '$a    ),' \
           -e '$a);' \
           -e '$a?>' \
    /host/nextcloud/config/config.php

    # link the config to the app
    ln -sf /host/nextcloud/config/config.php /var/www/html/config/config.php &>/dev/null

    cd /var/www/html
    # install db and admin user
    /usr/local/bin/php occ maintenance:install --database "mysql" --database-name "${NEXTCLOUD_DB_NAME}" --database-user "${NEXTCLOUD_DB_USER}" --database-pass "${NEXTCLOUD_DB_PASSWORD}" --admin-user "admin" --admin-pass "${NEXTCLOUD_ADMIN_PASSWORD}" --database-host "mysql" --data-dir "/host/nextcloud/data"
    /usr/local/bin/php occ config:system:set trusted_domains 1 --value=${NEXTCLOUD_DOMAIN}

    # Don't run this again
    touch /host/nextcloud/firstrun

else
    echo "auto upgrade disabled"
    #occ upgrade
    #if [ \( $? -ne 0 \) -a \( $? -ne 3 \) ]; then
    #    echo "Trying ownCloud upgrade again to work around ownCloud upgrade bug..."
    #    occ upgrade
    #    if [ \( $? -ne 0 \) -a \( $? -ne 3 \) ]; then exit 1; fi
    #    occ maintenance:mode --off
    #    echo "...which seemed to work."
    #fi
fi

chown -R www-data:www-data /var/www/html
chown www-data:www-data /host/nextcloud/config/config.php
chown -R www-data:www-data /host/nextcloud/apps2
chown -R www-data:www-data /host/nextcloud/data

exec "$@"
