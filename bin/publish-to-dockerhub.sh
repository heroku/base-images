#!/usr/bin/env bash

set -euo pipefail
set -x

nightlyTag="${IMAGE_TAG}.nightly"
nightlyBuildTag="${IMAGE_TAG}-build.nightly"
date=$(date -u '+%Y-%m-%d-%H.%M.%S')
dateTag="${PRIVATE_IMAGE_TAG}.${date}"
dateBuildTag="${PRIVATE_IMAGE_TAG}-build.${date}"

bin/build.sh "${STACK}" "${nightlyTag}" "${nightlyBuildTag}"

# Disable tracing temporarily to prevent logging DOCKER_HUB_PASSWORD.
(set +x; echo "${DOCKER_HUB_PASSWORD}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin)

docker push "${nightlyTag}"

docker tag "${nightlyTag}" "${dateTag}"
docker push "${dateTag}"

docker push "${nightlyBuildTag}"

docker tag "${nightlyBuildTag}" "${dateBuildTag}"
docker push "${dateBuildTag}"

if [[ -v CIRCLE_TAG ]]; then
  releaseTag="${IMAGE_TAG}.${CIRCLE_TAG}"
  releaseBuildTag="${IMAGE_TAG}-build.${CIRCLE_TAG}"
  latestTag="${IMAGE_TAG}"
  latestBuildTag="${IMAGE_TAG}-build"

  docker tag "${nightlyTag}" "${releaseTag}"
  docker tag "${nightlyTag}" "${latestTag}"

  docker push "${releaseTag}"
  docker push "${latestTag}"

  docker tag "${nightlyBuildTag}" "${releaseBuildTag}"
  docker tag "${nightlyBuildTag}" "${latestBuildTag}"

  docker push "${releaseBuildTag}"
  docker push "${latestBuildTag}"
fi
