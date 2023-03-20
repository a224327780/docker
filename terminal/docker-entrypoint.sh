#!/bin/sh
set -e

pwd="123456"
if [ -n "${PASSWORD}" ]; then
    pwd=${PASSWORD}
fi

exec /usr/local/bin/gotty --reconnect --permit-write --credential root:"${pwd}"