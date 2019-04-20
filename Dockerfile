FROM ubuntu:18.04

ARG TINI_VERSION='0.18.0'
ARG PHP_VERSION='7.3'

RUN apt-get update \
    && apt-get install -y \
        # Essential
        wget tar git curl nano man htop bash-completion openssh-server socat gnupg2 \
        # GUI
        libgtk2.0-0 libcanberra-gtk-module libxext6 libxrender1 libxtst6 libxslt1.1 dmz-cursor-theme \
    # tzdata
    && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
        && ln -fs /usr/share/zoneinfo/Europe/Chisinau /etc/localtime \
        && dpkg-reconfigure --frontend noninteractive tzdata \
    # PHP
    && apt-get install -y software-properties-common \
        && add-apt-repository -y ppa:ondrej/php \
        && apt-get install -y \
            php${PHP_VERSION} \
            php${PHP_VERSION}-curl \
            php${PHP_VERSION}-dev \
            php${PHP_VERSION}-gd \
            php${PHP_VERSION}-mbstring \
            php${PHP_VERSION}-zip \
            php${PHP_VERSION}-mysql \
            php${PHP_VERSION}-xml \
            php${PHP_VERSION}-pgsql \
            php-pear \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p ~/.ssh \
    && ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

ENTRYPOINT ["/tini", "--"]

CMD ["sleep", "infinity"]
