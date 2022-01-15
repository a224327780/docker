#!/bin/sh
set -e

# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
  set -- redis-server "$@"
fi

exec "$@"
