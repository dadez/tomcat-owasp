#!/bin/sh
set -e

# allow the container to be started with `--user`
if [ "$1" = 'catalina.sh run' -a "$(id -u)" = '0' ]; then
	chown -R tomcat .
	exec su-exec tomcat "$0" "$@"
fi

exec "$@"
