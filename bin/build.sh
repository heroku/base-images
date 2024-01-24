#!/usr/bin/env bash

# This script is designed to operate in the following scenarios:
# - Local builds with Docker Desktop. In this mode, all resulting images will
#   be loaded into the local container store. It is recommended to
#   enable docker desktop's `containerd` store.
# - For CI tests and package list generation with linux docker. In this mode,
#   resulting images will be loaded into the local container store, but only for
#   the current platform. Linux docker is not able to store multiarch images
#   locally.
# - Publishing images in CI with linux docker. Pass in a REPO and SUFFIX
#   argument to publish images directly during the build. Since linux docker
#   is unable to store/reference multiarch images locally, the publish
#   process involves building/pushing an image to a registry, then retagging
#   it later. The `docker-container` driver is required in this mode. Enable
#   it with `docker buildx create --use`.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
. bin/stack-helpers.sh

STACK_VERSION=$1
REPO=${2:-"heroku/heroku"}
SUFFIX=${3:-}

[[ $STACK_VERSION == +([0-9]) ]] || abort "usage: $(basename "${BASH_SOURCE[0]}") STACK_VERSION [IMAGE_REPO] [TAG_SUFFIX]"

if [ -n "$SUFFIX" ]; then
    # If there is a tag suffix, this script is pushing to a remote registry.
    BUILD_ARGS=("--push")
else
    # Otherwise, load the image into the local image store.
    BUILD_ARGS=("--load")
fi

VARIANTS=("-build:")
if [ "$STACK_VERSION" -le 22 ]; then
    # heroku/heroku:22 and prior images do not support multiple chip
    # architectures or multiarch images. Instead, they are amd64 only.
    BUILD_ARGS+=("--platform=linux/amd64")
    # heroku/heroku:22 and prior images need separate *cnb* variants that
    # add compatibility for Cloud Native Buildpacks.
    VARIANTS+=("-cnb:" "-cnb-build:-build")
else
    # heroku/heroku:24 images and beyond are multiarch (amd64+arm64) images.
    # Linux docker can't currently store/retrieve multiarch images from it's
    # local store. Therefore, this script will build a multiarch image if it's
    # pushing to a remote tag, or if Docker Desktop is in use during a local
    # build. Otherwise, it will fallback to a single architecture build with
    # a warning.
    # Additionally, heroku/heroku:24 and beyond images include CNB specific
    # modifications, so separate *cnb* variants are not created.
    if [ -n "$SUFFIX" ] || docker version | grep -q 'Docker Desktop'; then
        BUILD_ARGS+=("--platform=linux/amd64,linux/arm64")
    else
        echo "Warning: building single architecture image due to platform limitations."
    fi
fi

write_package_list() {
    local image_tag="$1"
    local output_file="${2}/installed-packages.txt"
    echo '# List of packages present in the final image. Regenerate using bin/build.sh' > "$output_file"
    docker run --rm "$image_tag" dpkg-query --show --showformat='${Package}\n' >> "$output_file"
}

RUN_IMAGE_TAG="${REPO}:${STACK_VERSION}${SUFFIX}"
RUN_DOCKERFILE_DIR="heroku-${STACK_VERSION}"

[[ -d "${RUN_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${RUN_DOCKERFILE_DIR} not found"
display "Building ${RUN_DOCKERFILE_DIR} / ${RUN_IMAGE_TAG} image"
# The --pull option is used for the run image, so that the latest updates
# from upstream ubuntu images are included.
docker buildx build "${BUILD_ARGS[@]}" --pull \
    --tag "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}" | indent
write_package_list "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}"

for VARIANT in "${VARIANTS[@]}"; do
    VARIANT_NAME=$(echo "$VARIANT" | cut -d ":" -f 1)
    DEPENDENCY_NAME=$(echo "$VARIANT" | cut -d ":" -f 2)
    VARIANT_IMAGE_TAG="${REPO}:${STACK_VERSION}${VARIANT_NAME}${SUFFIX}"
    VARIANT_DOCKERFILE_DIR="heroku-${STACK_VERSION}${VARIANT_NAME}"
    DEPENDENCY_IMAGE_TAG="${REPO}:${STACK_VERSION}${DEPENDENCY_NAME}${SUFFIX}"

    [[ -d "${VARIANT_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${VARIANT_DOCKERFILE_DIR} not found"
    display "Building ${VARIANT_DOCKERFILE_DIR} / ${VARIANT_IMAGE_TAG} image"
    # The --pull option is not used for variants since they depend on images
    # built earlier in this script.
    docker buildx build "${BUILD_ARGS[@]}" \
        --build-arg "BASE_IMAGE=${DEPENDENCY_IMAGE_TAG}" \
        --tag "${VARIANT_IMAGE_TAG}" "${VARIANT_DOCKERFILE_DIR}" | indent

    # generate the package list for non-cnb variants. cnb variants don't
    # influence the list of installed packages.
    if [[ ! "$VARIANT_NAME" = -cnb* ]]; then
        write_package_list "$VARIANT_IMAGE_TAG" "$VARIANT_DOCKERFILE_DIR"
    fi
done

display "Size breakdown..."
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" \
    | grep -E "(ubuntu|heroku)" | sed '1!G;h;$!d' | indent
