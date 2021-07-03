FROM php:7.4-apache

ARG phabricator_commit_hash="e7d3bae2cc3fb5f462a6304dd0c243740442cdf9"

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
COPY ./docker-entrypoint.sh /usr/local/bin/

EXPOSE 80
WORKDIR /opt/phabricator

ENTRYPOINT ["docker-entrypoint.sh"]
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
CMD ["apache2-foreground"]
