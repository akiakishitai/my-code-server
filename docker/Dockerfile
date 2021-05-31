# Base: https://github.com/linuxserver/docker-code-server
FROM ghcr.io/linuxserver/code-server:latest

# pipefail: パイプの途中でコマンドが失敗したとき、終了コードをエラーコードで返す
# errexit(-e): コマンドがエラーステータスで終了した時点で、即座にプロセスを中止する
# nounset(-u): 未定義の変数を使っていた場合はエラーとする
# xtrace(-x): 実行するコマンドとその引数を表示する
SHELL ["/bin/bash", "-eu", "-o", "pipefail", "-c"]

ARG SERVER_USER=abc
ARG _APP_HOME="/app"

# https://flutter.dev/docs/get-started/install/linux
ENV FLUTTER_HOME="${_APP_HOME}/flutter"
# rustup: https://rust-lang.github.io/rustup/environment-variables.html
# Cargo: https://doc.rust-lang.org/cargo/reference/environment-variables.html
ENV RUSTUP_HOME="${_APP_HOME}/rustup" \
    CARGO_HOME="${_APP_HOME}/cargo"
# https://docs.volta.sh/advanced/installers
ENV VOLTA_HOME="${_APP_HOME}/volta"

# Prepare
RUN \
  echo '*** volta ***' && \
  mkdir -p ${VOLTA_HOME} && \
  echo '*** rustup ***' && \
  mkdir -p {${RUSTUP_HOME},${CARGO_HOME}} && \
  echo '*** prepare mount point for flutter ***' && \
  mkdir -p ${FLUTTER_HOME} && \
  echo '*** permissions ***' && \
  chown ${SERVER_USER}:${SERVER_USER} ${_APP_HOME}/* && \
  rm -rf \
    /tmp/* \
    /var/tmp/*

# Install
RUN \
  echo '*** install development tools for Flutter ***' && \
  apt-get clean && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa && \
  echo '*** cache clean ***' && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

### Cannot change user from 'abc', because of s6-overlay init ###
#RUN \
#  echo '*** change user name ***' && \
#  usermod --login ${CODE_USER} ${SERVER_USER} --comment "Code-Server Manager(oldname abc)" && \
#  groupmod --new-name ${CODE_USER} ${SERVER_USER}

COPY root/ /

### Set PATH environment variable
# Flutter
ENV PATH="$PATH:$FLUTTER_HOME/bin"
# Rust
ENV PATH="$PATH:${CARGO_HOME}/bin"
# Volta
ENV PATH="$PATH:$VOLTA_HOME/bin"

EXPOSE 8443
