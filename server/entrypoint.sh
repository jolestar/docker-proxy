#!/bin/bash
set -e

function gen-cert() {
    pushd /etc/docker-proxy/cert > /dev/null
    if [ ! -f ca.pem ]; then
        openssl req -new -newkey rsa:2048 -sha256 -days 1095 -nodes \
            -x509 -keyout key.pem -out ca.pem \
            -subj '/CN=squid-proxy/O=NULL/C=AU'
        chmod 600 key.pem
        openssl x509 -in ca.pem -outform DER -out ca.der
        cat key.pem ca.pem >> stunnel.pem
    else
        echo "Reusing existing certificate"
    fi
    openssl x509 -sha1 -in ca.pem -noout -fingerprint
    popd > /dev/null
    return $?
}

function gen-passwd() {
    pushd /etc/docker-proxy/cert > /dev/null
    if [ ! -f passwd ]; then
	PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
	htpasswd -b -c passwd docker-proxy $PASSWORD
	echo "username: docker-proxy password: $PASSWORD"
    else
        echo "Reusing existing passwd"
    fi
    popd > /dev/null
    return $?
}


create_log_dir() {
  mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

gen-cert || exit 1
gen-passwd || exit 1
create_log_dir
create_cache_dir

# allow arguments to be passed to squid3
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

echo "Starting stunnel"
stunnel /etc/docker-proxy/stunnel.conf
echo "Stunnel started"

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f /etc/docker-proxy/squid.conf -z
  fi
  echo "Starting squid..."
  exec $(which squid) -f /etc/docker-proxy/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi
