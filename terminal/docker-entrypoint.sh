#!/bin/sh
set -e

p=8080
if [ -n "${PORT}" ]; then
  p=${PORT}
fi

exec /usr/local/bin/gotty --permit-write --reconnect --port "${p}" /bin/zsh
