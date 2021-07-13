#!/bin/bash

set -e

# [ "$1" = "/usr/bin/supervisord" ] || exec "$@" || exit $?
[ "$1" = "apache2-foreground" ] || exec "$@" || exit $?

sleep 60;

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
./bin/config set metamta.default-address $PHABRICATOR_METAMTA_DEFAULT_ADDRESS
./bin/config set storage.mysql-engine.max-size 8388608
./bin/config set phabricator.developer-mode true
./bin/config set user.require-real-name false

# cat > conf/local/local.json << EOL
# {
#   "user.require-real-name": false,
#   "phabricator.developer-mode": true,
#   "storage.mysql-engine.max-size": 8388608,
#   "metamta.default-address": "$PHABRICATOR_METAMTA_DEFAULT_ADDRESS",
#   "phabricator.base-uri": "$PHABRICATOR_BASE_URI",
#   "phd.log-directory": "$PHABRICATOR_LOG_PHD_HOME",
#   "log.ssh.path": "$PHABRICATOR_LOG_SSH_PATH",
#   "log.access.path": "$PHABRICATOR_LOG_ACCESS_PATH",
#   "repository.default-local-path": "$PHABRICATOR_REPO_LOCAL_PATH",
#   "pygments.enabled": true,
#   "mysql.pass": "$MYSQL_PASS",
#   "mysql.user": "$MYSQL_USER",
#   "mysql.port": "$MYSQL_PORT",
#   "mysql.host": "$MYSQL_HOST"
# }
# EOL

# [ -v PHABRICATOR_CLUSTER_MAILERS_JSON ] && ./bin/config set cluster.mailers "$PHABRICATOR_CLUSTER_MAILERS_JSON"
# [ -v PHABRICATOR_METAMTA_DEFAULT_ADDRESS ] && ./bin/config set metamta.default-address $PHABRICATOR_METAMTA_DEFAULT_ADDRESS
# 
# if [ -v PHABRICATOR_STORAGE_LOCAL_PATH ]; then
# 	./bin/config set storage.local-disk.path "$PHABRICATOR_STORAGE_LOCAL_PATH"
# 	mkdir -p "$PHABRICATOR_STORAGE_LOCAL_PATH"
# 	chown -R www-data:www-data "$PHABRICATOR_STORAGE_LOCAL_PATH"
# fi

mkdir -p "$PHABRICATOR_REPO_LOCAL_PATH"
chown -R www-data:www-data "$PHABRICATOR_REPO_LOCAL_PATH"
mkdir -p "$PHABRICATOR_LOG_HOME"
chown www-data:www-data "$PHABRICATOR_LOG_HOME"

sed -i "s/ENGINE=MyISAM/ENGINE=InnoDB/g" resources/sql/quickstart.sql

./bin/storage -f upgrade || echo "Database has some errors."

./bin/phd start

exec "$@"
