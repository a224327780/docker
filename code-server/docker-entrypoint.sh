#!/bin/sh
set -e

AUTH="none"
if [ -n "${PASSWORD}" ]; then
    AUTH="password"
fi

port=7071
if [ -n "${PORT}" ]; then
    port=${PORT}
fi

exec /usr/bin/code-server --bind-addr 0.0.0.0:"${port}" \
	--user-data-dir /data/code-server/user-data \
	--extensions-dir /data/code-server/extensions \
	--app-name codespaces \
	--disable-telemetry \
	--auth "${AUTH}" /data/code-server/workspace

