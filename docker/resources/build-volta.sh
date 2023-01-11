#!/bin/sh
set -u

###### Install volta
#
# Failed to `cargo install` by volta
# env CARGO_BUILD_RUSTFLAGS="-C incremental=$CARGO_TARGET_DIR/incremental -L native=/usr/lib -lc" cargo install --git https://github.com/volta-cli/volta.git --tag "v${VERSION}"
#
######
if volta --version 2>&1 | grep -q "${VERSION}"; then
  echo '[SKIP] volta is installed...'
else
  VOLTA_SRC="$CARGO_TARGET_DIR/volta"
  git clone --depth 1 --branch "v${VERSION}" https://github.com/volta-cli/volta.git "$VOLTA_SRC"
  cd "$VOLTA_SRC" || exit 1
  # build and install
  cargo build --release
  cargo install --path . --locked --offline

  # STRIP
  strip "$CARGO_HOME/bin/volta"
fi
