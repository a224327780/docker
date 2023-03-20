#!/bin/sh
set -e

pwd="123456"
if [ -n "${PASSWORD}" ]; then
    pwd=${PASSWORD}
fi

/usr/local/bin/gotty --reconnect --credential root:"${pwd}" --permit-write /bin/zsh