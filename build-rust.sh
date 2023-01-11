#!/bin/sh
### alias docker='podman'
set -u

IMAGE_NAME="${IMAGE_NAME:-build-musl-rust}"
CARGO_VOLUME="${CARGO_VOLUME:-cargo-home}"
PROJECT_ROOT=$(dirname "$0")

if ! (type docker >/dev/null 2>&1) && (type podman >/dev/null 2>&1); then
  alias docker='podman'
fi

docker_run() {
  docker run --rm -t \
    --tmpfs /tmp/cargotmp \
    -v "${CARGO_VOLUME}:/cargo" \
    -v "${PROJECT_ROOT}/docker/resources:/usr/local/bin:ro" \
    "${IMAGE_NAME}" \
    "$@"
}

###### exa ######
# A modern replacement for ‘ls’.
# https://github.com/ogham/exa
docker_run env VERSION="0.10.1" build-exa.sh

###### git-interactive-rebase-tool ######
# Native cross-platform full feature terminal-based sequence editor for git interactive rebase.
# https://github.com/MitMaro/git-interactive-rebase-tool
docker_run env VERSION="2.2.0" build-interactive-rebase-tool.sh

###### volta ######
# The Hassle-Free JavaScript Tool Manager
# https://github.com/volta-cli/volta
# Failed to `cargo install` by volta
#docker_run env CARGO_BUILD_RUSTFLAGS="-C incremental=$CARGO_TARGET_DIR/incremental -L native=/usr/lib -lc" cargo install --git https://github.com/volta-cli/volta.git --tag "v${VERSION}" --offline
docker_run env VERSION="1.0.7" build-volta.sh
