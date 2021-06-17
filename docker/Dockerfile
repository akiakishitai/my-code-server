FROM golang:1.16-alpine AS build-go

WORKDIR /build

RUN apk --no-cache add git make

# Install ghq, to /go/bin
RUN git clone --depth 1 https://github.com/x-motemen/ghq
WORKDIR /build/ghq
RUN make install

# -----
# Download tools
FROM alpine:3.12 AS downloader
ARG TARGETARCH

WORKDIR /app

RUN apk --no-cache add curl

# ytt
ARG YTT_VERSION="0.34.0"
RUN \
  curl -sL \
    https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-${TARGETARCH} \
    -o ytt

# powerline-go
ARG POWERLINE_VERSION="1.21.0"
RUN \
  curl -sL \
    https://github.com/justjanne/powerline-go/releases/download/v${POWERLINE_VERSION}/powerline-go-linux-${TARGETARCH} \
    -o powerline-go

# add exectable permission for binaries
RUN chmod -R a+x /app

# -----
# Install PPA keyrings
# Base: https://github.com/linuxserver/docker-code-server
FROM ghcr.io/linuxserver/code-server:latest AS keyrings

WORKDIR /keyrings

ARG KEY_DIR="gnupg-ring:/keyrings"
ARG GNUPGHOME="/tmp/.gnupg"
ARG GNUPG_OPTIONS="--no-default-keyring --homedir ${GNUPGHOME} --keyserver keyserver.ubuntu.com"

RUN mkdir -m 700 ${GNUPGHOME}

# git-core
RUN \
  gpg ${GNUPG_OPTIONS} \
    --keyring ${KEY_DIR}/git-core-archive-keyring.gpg \
    --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24

# fish shell
RUN \
  gpg ${GNUPG_OPTIONS} \
    --keyring ${KEY_DIR}/fish-shell-archive-keyring.gpg \
    --recv-keys 59FDA1CE1B84B3FAD89366C027557F056DC33CA5

# add read permission for apt-get
RUN chmod -R a+r /keyrings

# -----
# Prepare directories, environment variables, ...

# Base: https://github.com/linuxserver/docker-code-server
FROM ghcr.io/linuxserver/code-server:latest AS prepare

# pipefail: パイプの途中でコマンドが失敗したとき、終了コードをエラーコードで返す
# errexit(-e): コマンドがエラーステータスで終了した時点で、即座にプロセスを中止する
# nounset(-u): 未定義の変数を使っていた場合はエラーとする
# xtrace(-x): 実行するコマンドとその引数を表示する
SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]

ARG _APP_HOME="/app"

# https://flutter.dev/docs/get-started/install/linux
ENV FLUTTER_HOME="${_APP_HOME}/flutter"
RUN mkdir -p ${FLUTTER_HOME}

# rustup: https://rust-lang.github.io/rustup/environment-variables.html
# Cargo: https://doc.rust-lang.org/cargo/reference/environment-variables.html
ENV RUSTUP_HOME="${_APP_HOME}/rustup" \
  CARGO_HOME="${_APP_HOME}/cargo"
RUN mkdir -p {${RUSTUP_HOME},${CARGO_HOME}}

# https://docs.volta.sh/advanced/installers
ENV VOLTA_HOME="${_APP_HOME}/volta"
RUN mkdir -p ${VOLTA_HOME}

# fix owner
ARG SERVER_USER=abc
RUN chown ${SERVER_USER}:${SERVER_USER} ${_APP_HOME}/*

## sources.list
# remove 'deb-src'
RUN sed -i -e "/^deb-src/d" /etc/apt/sources.list
# Software sources
COPY sources.list.d/ /etc/apt/sources.list.d/

### Set PATH environment variable
# Flutter
ENV PATH="$PATH:$FLUTTER_HOME/bin"
# Rust
ENV PATH="$PATH:${CARGO_HOME}/bin"
# Volta
ENV PATH="$PATH:$VOLTA_HOME/bin"

# -----
# MAIN Installer
FROM prepare AS installer
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH

SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]

ARG SERVER_USER=abc

# PPA keyrings
COPY --from=keyrings /keyrings /usr/share/keyrings/

# Install
RUN \
  apt-get clean && \
  apt-get update && \
  ### Install git (latest), fish shell
  apt-get install -y --no-install-recommends \
    git \
    fish && \
  echo '*** install development tools for Flutter ***' && \
  apt-get install -y --no-install-recommends \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa && \
  ### Utilities CLI tools
  apt-get install -y --no-install-recommends \
    ncdu \
    peco \
    tldr \
    && \
  echo '*** clean up ***' && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Copy tools
COPY --from=build-go /go/bin /usr/local/bin/
COPY --from=downloader /app /usr/local/bin/

### Cannot change user from 'abc', because of s6-overlay init ###
#RUN \
#  echo '*** change user name ***' && \
#  usermod --login ${CODE_USER} ${SERVER_USER} --comment "Code-Server Manager(oldname abc)" && \
#  groupmod --new-name ${CODE_USER} ${SERVER_USER}

COPY root/ /

EXPOSE 8443
