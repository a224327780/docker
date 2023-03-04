#!/bin/sh
set -e

AUTH="none"
if [ -n "${PASSWORD}" ]; then
    AUTH="password"
fi

if [ -z ${PROXY_DOMAIN+x} ]; then
    PROXY_DOMAIN_ARG=""
else
    PROXY_DOMAIN_ARG="--proxy-domain=${PROXY_DOMAIN}"
fi

exec /usr/bin/code-server --bind-addr 0.0.0.0:1235 \
	--user-data-dir /data/code-server/data \
	--extensions-dir /data/code-server/extensions 
	--disable-telemetry \
	--auth "${AUTH}" \
	"${PROXY_DOMAIN_ARG}" \
	/data/code-server/workspace 