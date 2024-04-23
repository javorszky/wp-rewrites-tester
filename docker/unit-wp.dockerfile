# note the import here!
# This is local-php from dockerfile unit-requesturi.dockerfile until we can get
# 1.33 tagged with the request URI changes in it.
FROM unit:local-php

# Install absolutely required packages without which WordPress does not start.
RUN apt update && apt install -y libicu-dev git wget
RUN docker-php-ext-install intl pdo_mysql mysqli 

# Install exif, opcache, shmop, sockets, and zip packages.
RUN apt install -y libzip-dev ghostscript
RUN docker-php-ext-install exif opcache shmop sockets zip

# Install ssh2 php module.
RUN apt install -y libssh2-1-dev libssh2-1
RUN pecl install ssh2
RUN docker-php-ext-enable ssh2

# Install imagick extension.
# NOTE: This is currently (on php 8.3 with imagick 3.7.0) unreliable, sometimes installs correctly,
# sometimes does not. Until this is fixed on pecl/imagick end, I am not installing this extension.
# It's not _needed_ for WordPress to run, only a nice addition.
# 
# @see https://github.com/Imagick/imagick/issues/640 if you want to follow along.
# RUN apt install -y libmagickwand-dev
# RUN pecl install imagick
# RUN docker-php-ext-enable imagick

# Install igbinary.
RUN pecl install igbinary
RUN docker-php-ext-enable igbinary

# Install redis.
RUN pecl install redis
RUN docker-php-ext-enable redis

# Install image (the php extension "image" per the handbook).
RUN apt install -y libpng-dev
RUN docker-php-ext-install gd

# Install bc (bcmath).
RUN docker-php-ext-install bcmath

WORKDIR /wpms/

COPY --from=wordpress:6.5-apache /usr/src/wordpress /wpms/

RUN mv wp-config-docker.php wp-config.php

RUN chown -R unit:unit /wpms/
