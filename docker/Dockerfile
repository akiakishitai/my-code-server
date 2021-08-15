# -----
# Golang tools
FROM golang:1.16-alpine AS build-go
WORKDIR /go/src

RUN \
  apk --no-cache add \
    git \
    binutils

### Install to '/go/bin' as static binary
SHELL [ "/bin/ash", "-c" ]
ENV CGO_ENABLED=0
#ARG GO_TAGS="-tag netgo"
ARG GO_INSTALL="go install -ldflags '-extldflags=-static'"
# ghq
ARG GHQ_VERSION="1.2.1"
RUN ${GO_INSTALL} github.com/x-motemen/ghq@v${GHQ_VERSION}

# pet
ARG PET_VERSION="0.3.6"
RUN \
  git clone --depth 1 --branch v${PET_VERSION} \
    https://github.com/knqyf263/pet.git \
    /go/src/github.com/knqyf263/pet
WORKDIR /go/src/github.com/knqyf263/pet
RUN \
  # security update
  go get -u golang.org/x/crypto@v0.0.0-20210813211128-0a44fdfbc16e && \
  go mod tidy && \
  go install -ldflags "-X github.com/knqyf263/pet/cmd.version=${PET_VERSION} -extldflags=-static"

WORKDIR /go/bin
RUN \
  for binary in ./* ; do \
    strip "$binary"; \
  done

# -----
# Rust tools
FROM rust:1.53-alpine AS build-rust

ENV CARGO_HOME=/cargo
WORKDIR ${CARGO_HOME}/bin

RUN \
  apk --no-cache add \
    #alpine-sdk \
    #build-base \
    clang \
    # git \
    musl-dev

# Install
ENV CC=clang
RUN \
  cargo install --version ^0.10.1 exa && \
  cargo install --version ^2.1.0 git-interactive-rebase-tool

# Reduce binary size
RUN \
  for binary in ./* ; do \
    strip "$binary"; \
  done

# -----
# Download tools
FROM alpine:3.12 AS downloader-base
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

RUN \
  apk --no-cache add \
    curl \
    unzip

### fonts
WORKDIR /fonts
SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]
RUN \
  curl -sL \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/RobotoMono.zip \
    -o /tmp/roboto.zip && \
  unzip /tmp/roboto.zip \
    -x "*Windows Compatible.ttf" "*Complete.ttf" && \
  # rename, to lower and change spaces to '-'.
  for f in *; do \
    lower=$(echo "$f" | tr '[:upper:]' '[:lower:]'); \
    rename=$(echo "$lower" | sed -r -e 's/ /-/g' -e 's/^(.*)-nerd-font.*ttf$/\1.ttf/g'); \
    mv "$f" "$rename"; \
  done

### tools
WORKDIR /app

# store *.tar.* files
RUN mkdir /tmp/tools

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

### download arm64 version
FROM downloader-base AS downloader-arm64
# fd
ARG FD_VERSION="8.2.1"
RUN \
  curl -sL \
    https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-arm-unknown-linux-musleabihf.tar.gz \
    -o /tmp/tools/fd.tar.gz

# tealdeer, is the tldr client in Rust.
ARG TEALDEER_VERSION="1.4.1"
RUN \
  curl -sL \
    https://github.com/dbrgn/tealdeer/releases/download/v${TEALDEER_VERSION}/tldr-linux-arm-musleabi \
    -o tldr

# hyperfine
ARG HYPERFINE_VERSION="1.11.0"
RUN \
  curl -sL \
    https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}/hyperfine-v${HYPERFINE_VERSION}-arm-unknown-linux-musleabihf.tar.gz \
    -o /tmp/tools/hyperfine.tar.gz

### download amd64 version
FROM downloader-base AS downloader-amd64
# fd
ARG FD_VERSION="8.2.1"
RUN \
  curl -sL \
    https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz \
    -o /tmp/tools/fd.tar.gz

# tealdeer, is the tldr client in Rust.
ARG TEALDEER_VERSION="1.4.1"
RUN \
  curl -sL \
    https://github.com/dbrgn/tealdeer/releases/download/v${TEALDEER_VERSION}/tldr-linux-x86_64-musl \
    -o tldr

# hyperfine
ARG HYPERFINE_VERSION="1.11.0"
RUN \
  curl -sL \
    https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}/hyperfine-v${HYPERFINE_VERSION}-x86_64-unknown-linux-musl.tar.gz \
    -o /tmp/tools/hyperfine.tar.gz

# hadolint ignore=DL3006
FROM downloader-${TARGETARCH} AS downloader
WORKDIR /app
SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]

### extract tools
# fd
RUN \
  tar xf \
    /tmp/tools/fd.tar.gz \
    "$(tar tf /tmp/tools/fd.tar.gz | grep '.*/fd$')" \
    --strip-components 1 && \
  chown root:root fd

# hyperfine
RUN \
  tar xf \
    /tmp/tools/hyperfine.tar.gz \
    "$(tar tf /tmp/tools/hyperfine.tar.gz | grep '.*/hyperfine$')" \
    --strip-components 1 && \
  chown root:root hyperfine

#RUN \
#  find /tmp/tools \
#    -type f \
#    -name "*.tar.gz" \
#    -exec tar -xf {} \;

# add exectable permission for binaries
RUN chmod -R a+x /app

# -----
# Install PPA keyrings
# Base: https://github.com/linuxserver/docker-code-server
FROM ghcr.io/linuxserver/code-server:latest AS keyrings

WORKDIR /keyrings

ARG KEY_DIR="gnupg-ring:/keyrings"
ARG GNUPGHOME="/tmp/.gnupg"
ARG GNUPG_OPTIONS="--no-default-keyring \
  --homedir ${GNUPGHOME} \
  --keyserver keyserver.ubuntu.com"

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

### custom font
# Copy fonts
ARG FONT_DEST="/usr/local/share/.config/yarn/global/node_modules/code-server/src/browser/media/"
COPY --from=downloader /fonts ${FONT_DEST}
COPY stylesheets ${FONT_DEST}
RUN \
  sed \
    -i 's@</head>@<link rel="stylesheet" href="{{CS_STATIC_BASE}}/src/browser/media/custom-fonts.css">\n</head>@g' \
    ${FONT_DEST}../pages/vscode.html

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
    && \
  echo '*** clean up ***' && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Copy tools
ARG COPY_BIN_DEST=/usr/local/bin/
COPY --from=build-go /go/bin ${COPY_BIN_DEST}
COPY --from=build-rust /cargo/bin ${COPY_BIN_DEST}
COPY --from=downloader /app ${COPY_BIN_DEST}

### Cannot change user from 'abc', because of s6-overlay init ###
#RUN \
#  echo '*** change user name ***' && \
#  usermod --login ${CODE_USER} ${SERVER_USER} --comment "Code-Server Manager(oldname abc)" && \
#  groupmod --new-name ${CODE_USER} ${SERVER_USER}

COPY root/ /

EXPOSE 8443
