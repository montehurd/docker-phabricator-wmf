startfresh:
	docker compose down || true
	docker container rm -f docker-phabricator-wmf_mysql_1 || true
	docker container rm -f docker-phabricator-wmf_phabricator_1 || true
	docker network rm -f docker-phabricator-wmf_default || true
	docker image rm -f mysql/mysql-server || true
	docker image rm -f docker-phabricator-wmf_phabricator || true
	rm -rf data || true
	docker compose up

createadminuser:
# run immediately after 'startfresh' completes to create an admin user named 'aaa'. only works on macOS hosts.
	osascript -e 'tell application "Google Chrome"' -e 'activate' -e 'open location "http://127.0.0.1/auth/register/"' -e 'delay 3' -e 'tell application "System Events"' -e 'keystroke tab' -e 'keystroke tab' -e 'keystroke tab' -e 'keystroke "aaa"' -e 'keystroke tab' -e 'keystroke "aaa"' -e 'keystroke tab' -e 'keystroke "aaa@aaa.com"' -e 'keystroke tab' -e 'keystroke return' -e 'end tell' -e 'end tell' || true

addfakedata:
	docker exec -t docker-phabricator-wmf_phabricator_1 /bin/bash -c "timeout --signal=SIGINT 5s /opt/phabricator/bin/lipsum generate users -f" || true
	docker exec -t docker-phabricator-wmf_phabricator_1 /bin/bash -c "timeout --signal=SIGINT 10s /opt/phabricator/bin/lipsum generate projects -f" || true
	docker exec -t docker-phabricator-wmf_phabricator_1 /bin/bash -c "timeout --signal=SIGINT 20s /opt/phabricator/bin/lipsum generate tasks -f" || true