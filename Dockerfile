FROM ubuntu:18.04

ARG TINI_VERSION='0.18.0'
ARG CPPCHECK_HTMLREPORT_VERSION='1.87'

RUN apt-get update \
    && apt-get install -y \
        # Essential
        wget tar unzip git curl nano man htop bash-completion openssh-server socat gnupg2 \
        # GUI
        libgtk2.0-0 libcanberra-gtk-module libxext6 libxrender1 libxtst6 libxslt1.1 dmz-cursor-theme \
        # for Chromium
        libgtk-3-0 libatk-bridge2.0-0 libx11-xcb1 libnss3 libxss1 \
        # Build
        make g++ cmake automake autoconf \
        # Development
        gdb gdbserver \
        # Code analisys
        gcovr cppcheck python-pygments valgrind \
        # GPU/OpenGL
        libglfw3-dev libassimp-dev libxinerama-dev libxcursor-dev libxi-dev mesa-utils mesa-utils-extra kmod \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD https://raw.githubusercontent.com/danmar/cppcheck/${CPPCHECK_HTMLREPORT_VERSION}/htmlreport/cppcheck-htmlreport /usr/local/bin/cppcheck-htmlreport
RUN chmod +x /usr/local/bin/cppcheck-htmlreport && chmod 755 /usr/local/bin/cppcheck-htmlreport

ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p ~/.ssh \
    && ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

ENTRYPOINT ["/tini", "--"]

CMD ["sleep", "infinity"]
