#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
. bin/stack-helpers.sh

[ $# -eq 3 ] || abort usage: $(basename "${BASH_SOURCE[0]}") STACK IMAGE_NAME BUILD_IMAGE_NAME

STACK=$1
IMAGE_TAG=$2
BUILD_IMAGE_TAG=$3
DOCKERFILE_DIR="$STACK"

echo $DOCKERFILE_DIR

[[ -d "$DOCKERFILE_DIR" ]] || abort fatal: stack "$STACK" not found

write_package_list() {
    local image_tag="$1"
    local output_file="${2}/installed-packages.txt"
    echo '# List of packages present in the final image. Regenerate using bin/build.sh' > "$output_file"
    docker run --rm "$image_tag" dpkg-query --show --showformat='${Package}\n' >> "$output_file"
}

if [[ "${STACK}" = "cedar-14" ]]; then
    display "Building ${STACK} combined image"
    if ! [[ -v ESM_USERNAME && -v ESM_PASSWORD ]]; then
        echo 'Error: ESM_USERNAME and ESM_PASSWORD must be set in the environment!'
        exit 1
    fi
    docker build --pull \
        --tag "${IMAGE_TAG}" \
        --build-arg ESM_USERNAME="${ESM_USERNAME}" \
        --build-arg ESM_PASSWORD="${ESM_PASSWORD}" \
        "${DOCKERFILE_DIR}" | indent
    write_package_list "${IMAGE_TAG}" "${DOCKERFILE_DIR}"
else
    display "Building ${STACK} main image"
    docker build --pull --tag "${IMAGE_TAG}" "${DOCKERFILE_DIR}" | indent
    write_package_list "${IMAGE_TAG}" "${DOCKERFILE_DIR}"

    display "Building $STACK build-time image"
    BUILD_DOCKERFILE_DIR="${DOCKERFILE_DIR}-build"
    # The --pull option is not used to ensure the build image variant is based on the
    # main stack image built above, rather than the one last published to Docker Hub.
    docker build --tag "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR" | indent
    write_package_list "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR"
fi

display "Size breakdown..."
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" \
    | grep -E "(ubuntu|heroku)" | sed '1!G;h;$!d' | indent
