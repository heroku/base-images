#!/bin/bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
. stack-helpers.sh

[ $# -eq 1 ] || abort usage: $(basename "${BASH_SOURCE[0]}") STACK

STACK="${1%/}"
IMAGE_TAG="heroku/${STACK/-/:}"
DOCKERFILE_DIR="$STACK"

[[ -d "$DOCKERFILE_DIR" ]] || abort fatal: stack "$STACK" not found

write_package_list() {
    local image_tag="$1"
    local output_file="${2}/installed-packages.txt"
    echo '# List of packages present in the final image. Regenerate using docker-build.sh' > "$output_file"
    docker run --rm "$image_tag" dpkg-query --show --showformat='${Package}\n' >> "$output_file"
}

display "Building $STACK main image"
docker build --pull --tag "$IMAGE_TAG" "$DOCKERFILE_DIR" | indent
write_package_list "$IMAGE_TAG" "$DOCKERFILE_DIR"

if [[ "$STACK" != "cedar-14" ]]; then
    display "Building $STACK build-time image"
    BUILD_IMAGE_TAG="${IMAGE_TAG}-build"
    BUILD_DOCKERFILE_DIR="${DOCKERFILE_DIR}-build"
    # The --pull option is not used to ensure the build image variant is based on the
    # main stack image built above, rather than the one last published to Docker Hub.
    docker build --tag "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR" | indent
    write_package_list "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR"
fi

display "Size breakdown..."
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" \
    | grep -E "(ubuntu|heroku)" | sort -k2n | indent
