#!/bin/bash

CONTAINER_ALREADY_STARTED="html/gate/fingerprint.json"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- Creating fingerprint --"
    fingerprint=$(cat /proc/sys/kernel/random/uuid | openssl sha1 | awk '{print $2}')
    jq -n --arg fingerprint "$fingerprint" '{fingerprint: $fingerprint }' > html/gate/fingerprint.json
fi

GATE_IP="${GATE_IP%\"}"
GATE_IP="${GATE_IP#\"}"
export GATE_IP

GATE_PORT="${GATE_PORT%\"}"
GATE_PORT="${GATE_PORT#\"}"
export GATE_PORT

envsubst '${GATE_IP}, ${GATE_PORT}' < /usr/local/openresty/nginx/conf/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf
printf "\n Starting iGate With following:\n"
cat /usr/local/openresty/nginx/conf/nginx.conf

exec "$@"