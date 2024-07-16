FROM php:8.2-fpm

# persistent dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
        # Ghostscript is required for rendering PDF previews
		ghostscript \
	; \
	rm -rf /var/lib/apt/lists/*

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev \
		libcurl4-openssl-dev \
		libxml2-dev \
		unixodbc-dev \
		unixodbc \
		libldap2-dev \
		libpq-dev \
        libxslt-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		mysqli \
		zip \
	; 
RUN \    
	pecl install imagick; \
	docker-php-ext-enable imagick; \
	\
	docker-php-ext-install pdo; \
	\
	docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
	docker-php-ext-install pdo_mysql; \
	\
	docker-php-ext-install pdo_pgsql pgsql; \
    docker-php-ext-install soap sockets; \
    docker-php-ext-install xml; 

RUN \ 	
    EXTRA_CFLAGS="-I/usr/src/php" docker-php-ext-install xmlreader; 
    #docker-php-ext-install xmlwriter xsl tokenizer; 
    
RUN set -eux; \
	docker-php-source extract; \
	{ \
		echo '# https://github.com/docker-library/php/issues/103#issuecomment-271413933'; \
		echo 'AC_DEFUN([PHP_ALWAYS_SHARED],[])dnl'; \
		echo; \
		cat /usr/src/php/ext/odbc/config.m4; \
	} > temp.m4; \
	mv temp.m4 /usr/src/php/ext/odbc/config.m4; \
	\
    docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr/;\
    docker-php-ext-install pdo_odbc \
    && cd /usr/src/php/ext/odbc \
    && phpize \
    && sed -ri 's@^ *test +"\$PHP_.*" *= *"no" *&& *PHP_.*=yes *$@#&@g' configure \
    && ./configure --with-unixODBC=shared,/usr \
    && docker-php-ext-install odbc;	\
	\
	docker-php-ext-configure ldap ; \
	docker-php-ext-install ldap ; 
RUN set -eux; \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	# apt-mark auto '.*' > /dev/null; \
	# apt-mark manual $savedAptMark; \
	# ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
	# 	| awk '/=>/ { print $3 }' \
	# 	| sort -u \
	# 	| xargs -r dpkg-query -S \
	# 	| cut -d: -f1 \
	# 	| sort -u \
	# 	| xargs -rt apt-mark manual; \
	# \
	# apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*
    
RUN set -eux; \
	pecl install xdebug; \
	pecl install redis; \
    docker-php-ext-enable redis;


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -eux; \
	docker-php-ext-enable opcache; \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN set -ex \
    && cd /tmp \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /tmp/*

RUN docker-php-source delete;
#RUN ln -s /usr/lib/x86_64-linux-gnu/libodbccr.so.2 /usr/lib/x86_64-linux-gnu/libodbccr.so
WORKDIR /app
