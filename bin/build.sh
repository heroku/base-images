#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
. bin/stack-helpers.sh

STACK_VERSION=${1:-"NAN"}
REPO=${2:-"heroku/heroku"}
PUBLISH_SUFFIX=${3:-}
BASE_NAME=$(basename "${BASH_SOURCE[0]}")

print_usage(){
	echo "usage: ${BASE_NAME}  STACK_VERSION [IMAGE_REPO] [PUBLISH_SUFFIX]"
	cat <<-EOF

		This script builds heroku base images and writes package lists. It builds
		multi-arch images for heroku-24 and newer, and amd64 images for heroku-22 and
		older. It works in the following scenarios:

		Local builds with Docker Desktop and the 'containerd' snapshotter. In this
		mode, all resulting images will be loaded into the local container store.
		The 'default' and 'docker-container' drivers both work in this mode.
		Note that the 'containerd' snapshotter is not compatible with 'pack'.

		For CI tests and package list generation with Docker and the 'default'
		Docker driver. In this mode, resulting images will be loaded into the
		local container store, the package lists generated, but only for amd64.
		The 'default' Docker driver is not able to store/retreive multi-arch images
		locally with the default snapshotter, and the 'containerd' snapshotter is
		only available with Docker Desktop. The 'docker-container' driver will not
		work in this mode (it can't load any images from the default local store).

		Publishing images in CI with Docker and the 'docker-container'
		driver. Pass in a REPO and PUBLISH_SUFFIX argument to publish images
		directly during the build. Since Docker is unable to store/reference
		multi-arch images locally, the publish process involves building+pushing
		an image to a disposable tag, then retagging it. The 'default' Docker
		driver will not work in this mode (it can't build cross-architecture).
	EOF
}

[[ $STACK_VERSION =~ ^[0-9]+$ ]] || (print_usage >&2 && exit 2)

docker_container_driver=$(docker buildx inspect | grep -q "docker-container"; echo -n "${PIPESTATUS[1]}")

containerd_snapshotter=$(docker info | grep -q "io.containerd.snapshotter"; echo -n "${PIPESTATUS[1]}")

if [ "$STACK_VERSION" -le 22 ]; then
	# heroku/heroku:22 and prior images do not support multiple chip
	# architectures or multi-arch images. Instead, they are amd64 only.
	DOCKER_ARGS=("build" "--platform=linux/amd64")
	# heroku/heroku:22 and prior images need separate *cnb* variants that
	# add compatibility for Cloud Native Buildpacks.
	VARIANTS=("-build:" "-cnb:" "-cnb-build:-build")
else
	# heroku/heroku:24 images and beyond are multi-arch (amd64+arm64) images.
	# Due to weak feature support parity between Docker on Linux and Docker
	# Desktop building and publishing across platforms has caveats (see the
	# top of this file).
	if [ "$containerd_snapshotter" = 0 ] || { [ -n "$PUBLISH_SUFFIX" ] && [ "$docker_container_driver" -eq 0 ]; }; then
		DOCKER_ARGS=("buildx" "build" "--platform=linux/amd64,linux/arm64")
	elif [ -z "$PUBLISH_SUFFIX" ] && [ "$docker_container_driver" -ne 0 ]; then
		DOCKER_ARGS=("buildx" "build" "--platform=linux/amd64")
		echo "WARNING: heroku-24 and newer images are multi-arch images," \
			"but this script is building single architecture images" \
			"due to limitations of the current platform." \
			"To build a multi-arch image, enable the 'containerd'" \
			"snapshotter in Docker Desktop and/or use a 'docker-container'" \
			"Docker BuildKit driver." >&2
	else
		echo "ERROR: Can't build images with this configuration. Enable" \
			"the 'containerd' snapshotter in Docker Desktop, enable" \
			"the 'docker-container' driver in Docker, or use this script" \
			"in build-only mode (don't provide PUBLISH_SUFFIX argument)." >&2
		exit 1
	fi
	# heroku/heroku:24 and beyond images include CNB specific
	# modifications, so separate *cnb* variants are not created.
	VARIANTS=("-build:")
fi

if [ -n "$PUBLISH_SUFFIX" ]; then
	# If there is a tag suffix, this script is pushing to a remote registry.
	DOCKER_ARGS+=("--push")
else
	# Otherwise, load the image into the local image store.
	DOCKER_ARGS+=("--load")
fi

write_package_list() {
	local image_tag="$1"
	local dockerfile_dir="$2"

	# Extract the stack version from the dockerfile_dir variable (e.g., heroku-24)
	local stack_version
	stack_version=$(echo "$dockerfile_dir" | sed -n 's/^heroku-\([0-9]*\).*$/\1/p')

	local archs=("amd64")
	# heroku-24 and newer are multiarch. If containerd is available,
	# the package list for each architecture can be generated.
	if [ "$stack_version" -ge 24 ]; then
		if [ "$containerd_snapshotter" = 0 ]; then
			archs+=(arm64)
		else
			echo "WARNING: Generating package list for single architecture." \
				"Use the \`containerd\` snapshotter to generate package lists" \
				"for all architectures." >&2
		fi
	fi
	local output_file=""
	for arch in "${archs[@]}"; do
		if [ "${stack_version}" -ge 24 ]; then
			output_file="${dockerfile_dir}/installed-packages-${arch}.txt"
		else
			output_file="${dockerfile_dir}/installed-packages.txt"
		fi
		echo "Generating package list: ${output_file}"
		echo "# List of packages present in the final image. Regenerate using bin/build.sh" > "$output_file"
		docker run --rm --platform="linux/${arch}" "$image_tag" dpkg-query --show --showformat='${Package}\n' >> "$output_file"
	done
}

RUN_IMAGE_TAG="${REPO}:${STACK_VERSION}${PUBLISH_SUFFIX}"
RUN_DOCKERFILE_DIR="heroku-${STACK_VERSION}"

[[ -d "${RUN_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${RUN_DOCKERFILE_DIR} not found"
display "Building ${RUN_DOCKERFILE_DIR} / ${RUN_IMAGE_TAG} image"
# The --pull option is used for the run image, so that the latest updates
# from upstream ubuntu images are included.
docker "${DOCKER_ARGS[@]}" --pull \
	--tag "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}" | indent
	write_package_list "${RUN_IMAGE_TAG}" "${RUN_DOCKERFILE_DIR}"

	for VARIANT in "${VARIANTS[@]}"; do
		VARIANT_NAME=$(echo "$VARIANT" | cut -d ":" -f 1)
		DEPENDENCY_NAME=$(echo "$VARIANT" | cut -d ":" -f 2)
		VARIANT_IMAGE_TAG="${REPO}:${STACK_VERSION}${VARIANT_NAME}${PUBLISH_SUFFIX}"
		VARIANT_DOCKERFILE_DIR="heroku-${STACK_VERSION}${VARIANT_NAME}"
		DEPENDENCY_IMAGE_TAG="${REPO}:${STACK_VERSION}${DEPENDENCY_NAME}${PUBLISH_SUFFIX}"

		[[ -d "${VARIANT_DOCKERFILE_DIR}" ]] || abort "fatal: directory ${VARIANT_DOCKERFILE_DIR} not found"
		display "Building ${VARIANT_DOCKERFILE_DIR} / ${VARIANT_IMAGE_TAG} image"
		# The --pull option is not used for variants since they depend on images
		# built earlier in this script.
		docker "${DOCKER_ARGS[@]}" --build-arg "BASE_IMAGE=${DEPENDENCY_IMAGE_TAG}" \
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
