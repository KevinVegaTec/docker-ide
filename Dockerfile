FROM ubuntu:18.04

ARG TINI_VERSION='0.18.0'
ARG NODEJS_VERSION='10'
ARG NPM_VERSION='6.11.2'

RUN apt-get update \
    && apt-get install -y \
        # Essential
        wget tar git curl nano man htop bash-completion openssh-server socat gnupg2 \
        # GUI
        libgtk2.0-0 libcanberra-gtk-module libxext6 libxrender1 libxtst6 libxslt1.1 dmz-cursor-theme \
        # for Chromium
        libgtk-3-0 libatk-bridge2.0-0 libx11-xcb1 libnss3 libxss1 \
    && (curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -) \
    && apt-get install -y \
        build-essential nodejs \
        && npm install -g npm@${NPM_VERSION} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p ~/.ssh \
    && ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

ENTRYPOINT ["/tini", "--"]

CMD ["sleep", "infinity"]
