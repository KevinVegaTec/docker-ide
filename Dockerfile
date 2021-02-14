FROM ubuntu:20.04

ARG TINI_VERSION='0.18.0'
ARG PHP_VERSION='7.4'
ARG COMPOSER_VERSION='2.0.8'
ARG NODEJS_VERSION='10'
ARG NPM_VERSION='6.14.11'

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update \
    && apt-get install -y \
        # Essential
        wget tar unzip git curl nano man htop bash-completion openssh-server socat gnupg2 \
        # GUI
        libgtk2.0-0 libcanberra-gtk-module libxext6 libxrender1 libxtst6 libxslt1.1 dmz-cursor-theme \
        # for VsCode
        libxcb-dri3-0 libdrm-dev libgbm-dev \
        # for Chromium
        libgtk-3-0 libatk-bridge2.0-0 libx11-xcb1 libnss3 libxss1 \
    # tzdata
    && truncate -s0 /tmp/preseed.cfg \
        && echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg \
        && echo "tzdata tzdata/Zones/Europe select Chisinau" >> /tmp/preseed.cfg \
        && debconf-set-selections /tmp/preseed.cfg \
        && rm -f /etc/timezone /etc/localtime \
        && apt-get install -y tzdata \
    # PHP
    && apt-get install -y software-properties-common \
        && apt-get install -y \
            php${PHP_VERSION} \
            php${PHP_VERSION}-curl \
            php${PHP_VERSION}-dev \
            php${PHP_VERSION}-gd \
            php${PHP_VERSION}-mbstring \
            php${PHP_VERSION}-zip \
            php${PHP_VERSION}-sqlite3 \
            php${PHP_VERSION}-mysql \
            php${PHP_VERSION}-pgsql \
            php${PHP_VERSION}-xml \
            php${PHP_VERSION}-amqp \
            php${PHP_VERSION}-intl \
            php${PHP_VERSION}-redis \
            php-pear \
    && apt-get install -y libmagickwand-dev \
        && pecl install imagick \
        && echo "extension=$(find /usr/lib/php -iname imagick.so)" > /etc/php/${PHP_VERSION}/cli/conf.d/20-imagick.ini \
    # Debugger
    && pecl install xdebug \
        && echo "zend_extension=$(find /usr/lib/php -iname xdebug.so)" > /etc/php/${PHP_VERSION}/cli/conf.d/30-xdebug.ini \
        && echo 'xdebug.mode=debug' >> /etc/php/${PHP_VERSION}/cli/conf.d/30-xdebug.ini \
        && echo 'xdebug.client_port=9000' >> /etc/php/${PHP_VERSION}/cli/conf.d/30-xdebug.ini \
        && echo 'xdebug.remote_enable=1' >> /etc/php/${PHP_VERSION}/cli/conf.d/30-xdebug.ini \
        && echo 'xdebug.idekey="docker-ide"' >> /etc/php/${PHP_VERSION}/cli/conf.d/30-xdebug.ini \
    # Composer
    && wget https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar -O /usr/bin/composer -q \
        && chmod +x /usr/bin/composer \
    # JS
    && (curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -) \
        && apt-get install -y build-essential nodejs \
        && npm install -g npm@${NPM_VERSION} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p ~/.ssh \
    && ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

ENTRYPOINT ["/tini", "--"]

CMD ["sleep", "infinity"]
