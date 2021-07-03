#!/bin/bash

set -e

MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_USER=${MYSQL_USER:-phabricator}
MYSQL_PASS=${MYSQL_PASS:-phabricator}

export PHABRICATOR_HOST=${PHABRICATOR_HOST:-example.jp}
export PHABRICATOR_BASE_URI=${PHABRICATOR_BASE_URI:-http://$PHABRICATOR_HOST}
export PHABRICATOR_REPO_LOCAL_PATH=${PHABRICATOR_REPO_LOCAL_PATH:-/var/repo}
export PHABRICATOR_LOG_HOME=${PHABRICATOR_LOG_HOME:-/var/log/phabricator}
export PHABRICATOR_LOG_ACCESS_PATH=${PHABRICATOR_LOG_ACCESS_PATH:-$PHABRICATOR_LOG_HOME/access.log}
export PHABRICATOR_LOG_SSH_PATH=${PHABRICATOR_LOG_SSH_PATH:-$PHABRICATOR_LOG_HOME/ssh.log}
export PHABRICATOR_LOG_PHD_HOME=${PHABRICATOR_LOG_PHD_HOME:-/var/tmp/phd/log}

# [ "$1" = "/usr/bin/supervisord" ] || exec "$@" || exit $?
[ "$1" = "apache2-foreground" ] || exec "$@" || exit $?

while ! nc -vz ${MYSQL_HOST} ${MYSQL_PORT};
do
        echo Connect MySQL...
        echo sleeping;
        sleep 1;
done;
echo MySQL Connected!;

echo "Start configuration..."
./bin/config set mysql.host $MYSQL_HOST
./bin/config set mysql.port $MYSQL_PORT
./bin/config set mysql.user $MYSQL_USER
./bin/config set mysql.pass $MYSQL_PASS
./bin/config set pygments.enabled true
./bin/config set repository.default-local-path "$PHABRICATOR_REPO_LOCAL_PATH"
./bin/config set log.access.path "$PHABRICATOR_LOG_ACCESS_PATH"
./bin/config set log.ssh.path "$PHABRICATOR_LOG_SSH_PATH"
./bin/config set phd.log-directory "$PHABRICATOR_LOG_PHD_HOME"
./bin/config set phabricator.base-uri $PHABRICATOR_BASE_URI
./bin/config set storage.mysql-engine.max-size 8388608

[ -v PABRICATOR_CLUSTER_MAILERS_JSON ] && ./bin/config set cluster.mailers "$PABRICATOR_CLUSTER_MAILERS_JSON"
[ -v PABRICATOR_METAMTA_DEFAULT_ADDRESS ] && ./bin/config set metamta.default-address $PABRICATOR_METAMTA_DEFAULT_ADDRESS

if [ -v PHABRICATOR_STORAGE_LOCAL_PATH ]; then
	./bin/config set storage.local-disk.path "$PHABRICATOR_STORAGE_LOCAL_PATH"
	mkdir -p "$PHABRICATOR_STORAGE_LOCAL_PATH"
	chown -R www-data:www-data "$PHABRICATOR_STORAGE_LOCAL_PATH"
fi

mkdir -p "$PHABRICATOR_REPO_LOCAL_PATH"
chown -R www-data:www-data "$PHABRICATOR_REPO_LOCAL_PATH"
mkdir -p "$PHABRICATOR_LOG_HOME"
chown www-data:www-data "$PHABRICATOR_LOG_HOME"

sed -i "s/ENGINE=MyISAM/ENGINE=InnoDB/g" resources/sql/quickstart.sql

./bin/storage -f upgrade || echo "Database has some errors."

./bin/phd start

exec "$@"
