FROM php:7.4-fpm

RUN apt-get update 
RUN apt-get install -y libgmp-dev libpng-dev libfreetype6-dev libjpeg62-turbo-dev unzip \
    default-mysql-client libmagickwand-dev cron zlib1g-dev libzip-dev \ 
    curl  git cron htop supervisor libxml2-dev \ 
    --no-install-recommends

# Install NODE
SHELL ["/bin/bash", "--login", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash 
RUN nvm install 13.5.0 && nvm use 13.5.0 

# Install exetencions
RUN pecl install imagick \
    && docker-php-ext-enable imagick \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && docker-php-ext-install gmp \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-install simplexml

# Installing IMAP for PHP
# RUN apt update && apt install -y libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*
RUN apt update && apt install -y libc-client-dev libkrb5-dev
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

RUN docker-php-ext-configure gd \
    && docker-php-ext-install gd
RUN docker-php-ext-install calendar && docker-php-ext-configure calendar

# Configurations for PHP config init
RUN touch /usr/local/etc/php/conf.d/espconfig.ini \
    && echo "upload_max_filesize = 50M;" >> /usr/local/etc/php/conf.d/espconfig.ini \
    && echo "max_execution_time = 300;" >> /usr/local/etc/php/conf.d/espconfig.ini

# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*"

# Setup working directory
WORKDIR /var/www
