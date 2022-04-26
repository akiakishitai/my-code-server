#!/bin/sh
set -u

###### exa ######
# A modern replacement for ‘ls’.
# https://github.com/ogham/exa
if exa --version | grep -q v"${VERSION}"; then
  echo "[SKIP] exa is installed..."
else
  cargo install --version ^"${VERSION}" exa

  # STRIP
  strip "$CARGO_HOME/bin/exa"
fi
