FROM ubuntu:16.04
MAINTAINER jolestar@gmail.com

ENV SQUID_VERSION=3.5.12 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy \
    CERT_DIR=/etc/docker-proxy/cert \
    STUNNEL_VERSION=3:5.30

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y squid=${SQUID_VERSION}* \
 && mkdir /etc/docker-proxy/ \
 && mv /etc/squid/squid.conf /etc/docker-proxy/squid.conf.dist \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y stunnel4=${STUNNEL_VERSION}* \
 && apt-get install -y apache2-utils \
 && rm -rf /var/lib/apt/lists/*

COPY squid.conf /etc/docker-proxy/squid.conf
COPY stunnel.conf /etc/docker-proxy/stunnel.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5000

VOLUME ["${SQUID_CACHE_DIR}", "${SQUID_LOG_DIR}", "${CERT_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
