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

exec /usr/bin/code-server --bind-addr 0.0.0.0:7071 \
	--user-data-dir /data/code-server/data \
	--extensions-dir /data/code-server/extensions \
	--app-name codespaces \
	--disable-telemetry \
	--auth "${AUTH}" \
	/data/code-server/workspace 