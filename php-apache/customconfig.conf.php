<?php

return array(
  // Don't require e-mail verification
  // 'auth.require-email-verification' => false,

  // SMTP outbound info
  // 'cluster.mailers' => [
  //   [
  //     "key" => "smtp-outbound",
  //     "type" => "smtp",
  //     "options" => [
  //       'host' => 'localhost',
  //       'port' => 587,
  //       'protocol' => 'tls',
  //       'user' => 'username',
  //       'password' => 'password',
  //       'message-id' => true,
  //     ]
  //   ],
  // ],

  'metamta.default-address' => strval(getenv('PHABRICATOR_METAMTA_DEFAULT_ADDRESS')),

  'mysql.host' => strval(getenv('MYSQL_HOST')),
  'mysql.port' => strval(getenv('MYSQL_PORT')),
  'mysql.user' => strval(getenv('MYSQL_USER')),
  'mysql.pass' => strval(getenv('MYSQL_PASS')),

//  'phabricator.base-uri' => strval(getenv('PHABRICATOR_BASE_URI')),
  'pygments.enabled' => true,
  'storage.mysql-engine.max-size' => 8388608,
  'phabricator.developer-mode' => true,
  'user.require-real-name' => false,
  'repository.default-local-path' => strval(getenv('PHABRICATOR_REPO_LOCAL_PATH')),
  'log.access.path' => strval(getenv('PHABRICATOR_LOG_ACCESS_PATH')),
  'log.ssh.path' => strval(getenv('PHABRICATOR_LOG_SSH_PATH')),
  'phd.log-directory' => strval(getenv('PHABRICATOR_LOG_PHD_HOME')),
  'phabricator.timezone' => strval(getenv('DATE_TIMEZONE')),

  'security.require-https' => false,



  // Ignore some annoying things
  // 'config.ignore-issues' => [
  //   "cluster.mailers" => true,
  //   "security.security.alternate-file-domain" => true,
  // ],

  // Show prototypes
  // 'phabricator.show-prototypes' => true,  
);
