#!/bin/sh
set -e

pwd="123456"
port=8080
if [ -n "${PASSWORD}" ]; then
    pwd=${PASSWORD}
fi
if [ -n "${PORT}" ]; then
    port=${PORT}
fi

/usr/local/bin/gotty --port "${port}" --reconnect --credential root:"${pwd}" -w /bin/zsh