#!/bin/bash

set -e

# [ "$1" = "/usr/bin/supervisord" ] || exec "$@" || exit $?
[ "$1" = "apache2-foreground" ] || exec "$@" || exit $?

while ! nc -vz ${MYSQL_HOST} ${MYSQL_PORT};
do
        echo "Connect MySQL...";
        echo "sleeping";
        sleep 1;
done;
echo "MySQL Connected!";

./bin/storage -f upgrade || echo "Database has some errors."

./bin/phd start

exec "$@"