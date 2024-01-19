#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
. bin/stack-helpers.sh

[ $# -eq 1 ] || abort "usage: $(basename "${BASH_SOURCE[0]}") STACK_VERSION"

STACK_VERSION=$1

write_package_list() {
    local image_tag="$1"
    local output_file="${2}/installed-packages.txt"
    echo '# List of packages present in the final image. Regenerate using bin/build.sh' > "$output_file"
    docker run --rm "$image_tag" dpkg-query --show --showformat='${Package}\n' >> "$output_file"
}

RUN_IMAGE_TAG="heroku/heroku:${STACK_VERSION}"
RUN_DOCKERFILE_DIR="heroku-${STACK_VERSION}"

BUILD_IMAGE_TAG="${RUN_IMAGE_TAG}-build"
BUILD_DOCKERFILE_DIR="${RUN_DOCKERFILE_DIR}-build"

if [ "$STACK_VERSION" -ge 24 ]; then
    # heroku/heroku:24 images and beyond are multiarch images. Additionally,
    # the CNB specific modifications are included (separate *cnb* variants
    # do not exist).

    # NOTE: To build multiarch images with buildx, setup a builder that uses
    # the `docker-container` driver, and/or turn on the `containerd`
    # snapshotter storage. https://docs.docker.com/build/building/multi-platform/

    [[ -d "${RUN_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${RUN_DOCKERFILE_DIR} not found"
    display "Building multiarch ${RUN_DOCKERFILE_DIR} / ${RUN_IMAGE_TAG} Heroku run image"
    docker buildx build --platform "linux/amd64,linux/arm64" --pull --tag "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}" | indent
    write_package_list "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}"

    # The --pull option is not used for variants to ensure they are based on the
    # runtime stack image built above, rather than the one last published to DockerHub.
    [[ -d "${BUILD_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${BUILD_DOCKERFILE_DIR} not found"
    display "Building multiarch ${BUILD_DOCKERFILE_DIR} / ${BUILD_IMAGE_TAG} Heroku build image"
    docker buildx build --platform "linux/amd64,linux/arm64" --tag "${BUILD_IMAGE_TAG}" "${BUILD_DOCKERFILE_DIR}" | indent
    write_package_list "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR"
else
    # heroku/heroku:22 and prior does not support multiple chip architectures
    # or multiarch images. Additionally, separate *cnb* variants are created
    # which add compatibility for Cloud Native Buildpacks.

    [[ -d "${RUN_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${RUN_DOCKERFILE_DIR} not found"
    display "Building ${RUN_DOCKERFILE_DIR} / ${RUN_IMAGE_TAG} Heroku run image"
    docker build --pull --tag "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}" | indent
    write_package_list "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}"

    # The --pull option is not used for variants to ensure they are based on the
    # runtime stack image built above, rather than the one last published to Docker Hub.
    BUILD_DOCKERFILE_DIR="${RUN_DOCKERFILE_DIR}-build"
    display "Building ${BUILD_DOCKERFILE_DIR} / ${BUILD_IMAGE_TAG} Heroku build image"
    docker build --tag "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR" | indent
    write_package_list "$BUILD_IMAGE_TAG" "$BUILD_DOCKERFILE_DIR"

    # write_package_list is not needed for *cnb* variants, as they don't install
    # any additional packages over their non-*cnb* counterparts.
    CNB_RUN_IMAGE_TAG="${RUN_IMAGE_TAG}-cnb"
    CNB_RUN_DOCKERFILE_DIR="${RUN_DOCKERFILE_DIR}-cnb"
    display "Building ${CNB_RUN_DOCKERFILE_DIR} / ${CNB_RUN_IMAGE_TAG} CNB run image"
    docker build --tag "$CNB_RUN_IMAGE_TAG" "$CNB_RUN_DOCKERFILE_DIR" | indent

    CNB_BUILD_IMAGE_TAG="${RUN_IMAGE_TAG}-cnb-build"
    CNB_BUILD_DOCKERFILE_DIR="${RUN_DOCKERFILE_DIR}-cnb-build"
    display "Building ${CNB_BUILD_DOCKERFILE_DIR} / ${CNB_BUILD_IMAGE_TAG} CNB build image"
    docker build --tag "$CNB_BUILD_IMAGE_TAG" "$CNB_BUILD_DOCKERFILE_DIR" | indent
fi

display "Size breakdown..."
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" \
    | grep -E "(ubuntu|heroku)" | sed '1!G;h;$!d' | indent
