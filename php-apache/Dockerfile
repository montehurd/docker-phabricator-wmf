FROM php:7.4-apache

ARG phabricator_commit_hash="193798385bd3a7f72dca255e44f8112f4f8fc155"

RUN apt-get update && apt-get -y upgrade && \
	apt-get -y install git python3-pygments zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libldap2-dev netcat && \
	docker-php-ext-configure gd --with-jpeg --with-freetype && \
	docker-php-ext-install mysqli pcntl gd zip opcache ldap && \
	printf "\n" | pecl install apcu && \
	pecl install xhprof && \
	a2enmod rewrite && \
	cd /usr/local/etc/php/conf.d && \
	echo "extension=apcu.so" > pecl-apcu.ini && \
	echo "extension=xhprof.so" > pecl-xhprof.ini && \
	cd - && \
	cd /opt && \
	git clone --single-branch --branch stable https://github.com/phacility/phabricator && \
	git clone --single-branch --branch stable --depth 1 https://github.com/phacility/arcanist && \
	cd - && \
	cd /opt/phabricator && \
	git checkout $phabricator_commit_hash

COPY ./000-default.conf /etc/apache2/sites-available/
COPY ./php-user.ini /usr/local/etc/php/conf.d/
COPY ./entrypoint.sh /usr/local/bin/

EXPOSE 80
WORKDIR /opt/phabricator

ENV RUN_TIME=123                                                                                                       

ENV PHABRICATOR_HOST=127.0.0.1
ENV PHABRICATOR_BASE_URI=http://127.0.0.1
ENV PHABRICATOR_LOG_ACCESS_PATH=/var/log/phabricator/access.log
ENV PHABRICATOR_LOG_SSH_PATH=/var/log/phabricator/ssh.log
ENV PHABRICATOR_LOG_PHD_HOME=/var/tmp/phd/log
ENV PHABRICATOR_METAMTA_DEFAULT_ADDRESS=noreply@example.com
ENV DATE_TIMEZONE=America/Los_Angeles


# For PHP-based config
COPY ./customconfig.conf.php ./conf/custom/
ENV PHABRICATOR_ENV=custom/customconfig.conf.php

ARG repoPath=/var/repo
ENV PHABRICATOR_REPO_LOCAL_PATH=$repoPath
RUN mkdir -p $repoPath
RUN chown -R www-data:www-data $repoPath

ARG logHome=/var/log/phabricator
ENV PHABRICATOR_LOG_HOME=$logHome
RUN mkdir -p $logHome
RUN chown www-data:www-data $logHome

RUN sed -i "s/ENGINE=MyISAM/ENGINE=InnoDB/g" resources/sql/quickstart.sql

# ENTRYPOINT ["entrypoint.sh"]
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
# CMD ["apache2-foreground"]
