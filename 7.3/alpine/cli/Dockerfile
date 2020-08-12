FROM php:7.3-cli-alpine

# docker-entrypoint.sh dependencies
RUN apk add --no-cache \
# in theory, docker-entrypoint.sh is POSIX-compliant, but priority is a working, consistent image
		bash \
# BusyBox sed is not sufficient for some of our sed expressions
		sed

# install the PHP extensions we need
RUN set -ex; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		libjpeg-turbo-dev \
		libpng-dev \
		curl-dev \
		libxml2-dev \
		libmcrypt-dev \
		git \
		postgresql-dev \
		libzip-dev \
        zip \
		libldap \
		openldap-dev \
		oniguruma-dev \
	;

	RUN docker-php-ext-configure curl;
	RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd;
	RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr;
	
	RUN docker-php-ext-install bcmath
	RUN docker-php-ext-install curl
	RUN docker-php-ext-install gd
	RUN docker-php-ext-install json mbstring
	RUN docker-php-ext-install opcache
	RUN docker-php-ext-install fileinfo
	RUN docker-php-ext-install mysqli
	RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql pgsql

	RUN docker-php-ext-install soap sockets
	RUN docker-php-ext-install zip
	RUN docker-php-ext-install xmlrpc
	RUN docker-php-ext-install xml
	RUN docker-php-ext-install tokenizer
	# RUN docker-php-ext-install xml xmlreader xmlrpc xmlwriter xsl

	RUN docker-php-ext-configure ldap 
    RUN docker-php-ext-install ldap

	RUN set -ex; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .wordpress-phpexts-rundeps $runDeps; \
	apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN apk add --no-cache $PHPIZE_DEPS
RUN pecl install xdebug
RUN pecl install redis
RUN rm -rf /var/cache/apk/*
RUN apk del	$PHPIZE_DEPS
RUN pecl update-channels
RUN set -ex \
    && cd /tmp \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /tmp/*
RUN apk add --no-cache \
	git \
	openssh-client

RUN rm -rf /tmp/* ~/.pearrc
RUN rm -rf /usr/src/*

RUN docker-php-ext-enable redis
WORKDIR /app

