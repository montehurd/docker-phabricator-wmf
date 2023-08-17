#!/bin/bash

get_response_code() {
  # shellcheck disable=SC2005
  echo "$(curl --write-out '%{http_code}' --silent --output /dev/null "$1")"
}

wait_until_url_available() {
  while ! [[ "$(get_response_code "$1")" =~ ^(200|301)$ ]]; do sleep 1; done
  sleep 0.5
}

fresh_install() {
  remove
  start
  sleep 2
  add_fake_data
  sleep 2
  open_in_chrome
}

start() {
  echo -e "\nSpinning up containers..."
  docker compose up -d
  echo -e "\nStarting services..."
  wait_until_url_available "http://127.0.0.1/auth/register/"
}

remove() {
  echo -e "\nClearing out previous data if needed..."
  docker compose down || true
  docker image ls mysql/mysql-server -q | xargs -r docker image rm -f || true
  docker image rm -f docker-phabricator-wmf-phabricator || true
  rm -rf data || true
}

add_fake_data() {
  echo -e "\nAdding fake data..."
  create_admin_user
  add_fake_users
  add_fake_projects
  add_fake_tasks
}

create_admin_user() {
  # create an admin user named 'aaa'. only works on macOS hosts
  osascript -e 'tell application "Google Chrome"' -e 'activate' -e 'open location "http://127.0.0.1/auth/register/"' -e 'delay 3' -e 'tell application "System Events"' -e 'keystroke tab' -e 'keystroke tab' -e 'keystroke tab' -e 'keystroke "aaa"' -e 'keystroke tab' -e 'keystroke "aaa"' -e 'keystroke tab' -e 'keystroke "aaa@aaa.com"' -e 'keystroke tab' -e 'keystroke return' -e 'end tell' -e 'end tell' || true
}

open_in_chrome() {
  osascript -e 'tell application "Google Chrome"' -e 'activate' -e 'open location "http://127.0.0.1"' -e 'end tell' || true
}

add_fake_users() {
  docker exec -t docker-phabricator-wmf-phabricator-1 /bin/bash -c "timeout --signal=SIGINT 1s /opt/phabricator/bin/lipsum generate users -f --quickly" || true
}

add_fake_projects() {
  docker exec -t docker-phabricator-wmf-phabricator-1 /bin/bash -c "timeout --signal=SIGINT 1s /opt/phabricator/bin/lipsum generate projects -f --quickly" || true
}

add_fake_tasks() {
  docker exec -t docker-phabricator-wmf-phabricator-1 /bin/bash -c "timeout --signal=SIGINT 10s /opt/phabricator/bin/lipsum generate tasks -f --quickly" || true
}

"$@"
