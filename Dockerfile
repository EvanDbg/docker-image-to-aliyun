FROM ubuntu:18.04

# Packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    gpg \
    curl \
    wget \
    lsb-release \
    add-apt-key \
    ca-certificates \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Common SDK
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    sudo \
    gdb \
    pkg-config \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Code-Server
RUN apt-get update && apt-get install --no-install-recommends -y \
    bsdtar \
    openssl \
    locales \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV DISABLE_TELEMETRY true

ENV CODE_VERSION="3.4.1"
RUN curl -sL https://github.com/cdr/code-server/releases/download/${CODE_VERSION}/code-server-${CODE_VERSION}-linux-x86_64.tar.gz | tar --strip-components=1 -zx -C /usr/local/bin code-server-${CODE_VERSION}-linux-x86_64/code-server

# Setup theos
ENV THEOS /opt/theos
ENV PATH "$THEOS/bin:$PATH"
COPY setup.sh .
RUN ./setup.sh

# Setup User Visual Studio Code Extentions
ENV VSCODE_USER "/home/root/.local/share/code-server/User"
ENV VSCODE_EXTENSIONS "/home/root/.local/share/code-server/extensions"

RUN mkdir -p ${VSCODE_USER}
COPY settings.json /home/root/.local/share/code-server/User/

# Setup User Workspace
RUN mkdir -p /home/root/project
WORKDIR /home/root/project

EXPOSE 8080

ENTRYPOINT ["code-server"]
