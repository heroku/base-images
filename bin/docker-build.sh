#!/bin/bash

set -euo pipefail

cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
. bin/stack-helpers.sh

[ $# -eq 1 ] || abort usage: $(basename "${BASH_SOURCE[0]}") STACK

STACK="${1%/}"
IMAGE_TAG="heroku/${STACK/-/:}"
DOCKERFILE_DIR="$STACK"

# Remove this when cedar-14 is moved from the repository root to ./cedar-14/.
[[ "$STACK" = "cedar-14" ]] && DOCKERFILE_DIR="."

[[ -d "$DOCKERFILE_DIR" ]] || abort fatal: stack "$STACK" not found

display "Building $STACK main image"
docker build --pull --tag "$IMAGE_TAG" "$DOCKERFILE_DIR" | indent

if [[ "$STACK" != "cedar-14" ]]; then
    display "Building $STACK build-time image"
    # The --pull option is not used to ensure the build image variant is based on the
    # main stack image built above, rather than the one last published to Docker Hub.
    docker build --tag "${IMAGE_TAG}-build" "${DOCKERFILE_DIR}-build" | indent
fi

display "Size breakdown..."
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" \
    | grep -E "(ubuntu|heroku)" | tac | indent
