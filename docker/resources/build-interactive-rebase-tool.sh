#!/bin/sh
set -u

###### git-interactive-rebase-tool ######
# Native cross-platform full feature terminal-based sequence editor for git interactive rebase.
# https://github.com/MitMaro/git-interactive-rebase-tool
if interactive-rebase-tool --version 2>&1 | grep -q "${VERSION}"; then
  echo '[SKIP] interactive-rebase-tool is installed...'
else
  cargo install --version ^"${VERSION}" git-interactive-rebase-tool

  # STRIP
  strip "$CARGO_HOME/bin/interactive-rebase-tool"
fi
