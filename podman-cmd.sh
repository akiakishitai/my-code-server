#!/bin/bash

podname="my-code-server"
ctrname="code-server"
projectsrc="/config/.local/src/my-code-server"

podman pod rm --force "${podname}"
podman pod create --name "${podname}" --hostname "${podname}" --publish 8443:8443

podman run --rm -d \
  --pod "${podname}" --name "${ctrname}" --expose 8443 \
  --env PUID="${UID:-1000}" --env PGID="${GID:-1000}" --env TZ="Asia/Tokyo" \
  --env PASSWORD \
  --mount type=volume,src=coder-config,dst=/config \
  --mount type=volume,src=coder-app,dst=/app \
  --mount type=bind,src="$(pwd)",dst="${projectsrc}" \
  localhost/code-server:${CODE_SERVER_VERSION:-latest}
