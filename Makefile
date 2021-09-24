startfresh:
	docker compose down || true
	docker container rm -f docker-phabricator-wmf_mysql_1 || true
	docker container rm -f docker-phabricator-wmf_phabricator_1 || true
	docker network rm -f docker-phabricator-wmf_default || true
	docker image rm -f mysql/mysql-server || true
	docker image rm -f docker-phabricator-wmf_phabricator || true
	rm -rf data || true
	docker compose up