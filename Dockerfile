FROM eigenerserver/apache2:latest
#FROM eigenerserver/apache2:0.1.0

RUN apt-get update && \
    apt-get -y --no-install-recommends install wget bzip2 && \
    apt-get -y --no-install-recommends install --reinstall ca-certificates && \
    apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/*

ENV NEXTCLOUD_VERSION=12.0.0
ENV NEXTCLOUD_GPG="2880 6A87 8AE4 23A2 8372 792E D758 99B9 A724 937A"

RUN cd /tmp && \
    NEXTCLOUD_DOWNLOAD="nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" && \
    wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_DOWNLOAD} && \
    wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_DOWNLOAD}.sha256 && \
    wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_DOWNLOAD}.asc && \
    wget -q https://nextcloud.com/nextcloud.asc && \ 
    CHECK_1="$(echo -n $(sha256sum -c ${NEXTCLOUD_DOWNLOAD}.sha256) | tail -c 2)" && \
    if [ "${CHECK_1}" != "OK" ]; then echo "Checksum match error: ${CHECK_1}" && exit 1; fi && \
    gpg --import nextcloud.asc && \
    CHECK_2="$(echo -n $(gpg --verify nextcloud-12.0.0.tar.bz2.asc nextcloud-12.0.0.tar.bz2 2>&1 \
             | sed -n -e 's/^.*Primary key fingerprint: //p'  ))" && \
    if [ "${CHECK_2}" != "${NEXTCLOUD_GPG}" ]; then echo "Fingerprint match error: ${CHECK_2}" && exit 1; fi && \

    mkdir -p /var/www/html && \
    tar xjvf ${NEXTCLOUD_DOWNLOAD} --strip 1 -C /var/www/html && \
    ln -s /var/www/html /var/www/html/nextcloud && \
    rm -rf /tmp/*

ENV NEXTCLOUD_DB_NAME=eigenerserver
ENV NEXTCLOUD_DB_USER=eigenerserver
ENV NEXTCLOUD_DB_PASSWORD=eigenerserver
ENV NEXTCLOUD_DOMAIN=eigener-server.ch
ENV NEXTCLOUD_ADMIN_PASSWORD=eigenerserver

VOLUME ["/host/nextcloud"]

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/bin/bash","/usr/local/bin/run.sh"]

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
