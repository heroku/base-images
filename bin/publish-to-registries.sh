#!/usr/bin/env bash

set -euo pipefail
set -x

nightlyTag="${IMAGE_TAG}.nightly"
nightlyBuildTag="${IMAGE_TAG}-build.nightly"
date=$(date -u '+%Y-%m-%d-%H.%M.%S')
dateTag="${PRIVATE_IMAGE_TAG}.${date}"
dateBuildTag="${PRIVATE_IMAGE_TAG}-build.${date}"

bin/build.sh "${STACK}" "${nightlyTag}" "${nightlyBuildTag}"

# Disable tracing temporarily to prevent logging DOCKER_HUB_TOKEN.
(set +x; echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin)

docker push "${nightlyTag}"

docker tag "${nightlyTag}" "${dateTag}"
docker push "${dateTag}"

docker push "${nightlyBuildTag}"

docker tag "${nightlyBuildTag}" "${dateBuildTag}"
docker push "${dateBuildTag}"

if [[ -v CIRCLE_TAG ]]; then
  releaseTag="${IMAGE_TAG}.${CIRCLE_TAG}"
  releaseTagPrivate="${PRIVATE_REGISTRY_HOST}/s/${SERVICE_USERNAME}/${releaseTag}"

  releaseBuildTag="${IMAGE_TAG}-build.${CIRCLE_TAG}"
  releaseBuildTagPrivate="${PRIVATE_REGISTRY_HOST}/s/${SERVICE_USERNAME}/${releaseBuildTag}"

  latestTag="${IMAGE_TAG}"
  latestTagPrivate="${PRIVATE_REGISTRY_HOST}/s/${SERVICE_USERNAME}/${latestTag}"

  latestBuildTag="${IMAGE_TAG}-build"
  latestBuildTagPrivate="${PRIVATE_REGISTRY_HOST}/s/${SERVICE_USERNAME}/${latestBuildTag}"

  PRIVATE_REGISTRY_TOKEN=$(set +x; curl -f -X POST $SERVICE_TOKEN_ENDPOINT -d "{\"username\":\"$SERVICE_USERNAME\",\"password\":\"$SERVICE_PASSWORD\"}" -s --retry 3 | jq -r ".raw_id_token")
  (set +x; echo "${PRIVATE_REGISTRY_TOKEN}" | docker login $PRIVATE_REGISTRY_HOST -u "$PRIVATE_REGISTRY_USERNAME" --password-stdin)

  docker tag "${nightlyTag}" "${releaseTag}"
  docker tag "${nightlyTag}" "${releaseTagPrivate}"
  docker tag "${nightlyTag}" "${latestTag}"
  docker tag "${nightlyTag}" "${latestTagPrivate}"

  docker push "${releaseTag}"
  docker push "${releaseTagPrivate}"
  docker push "${latestTag}"
  docker push "${latestTagPrivate}"

  docker tag "${nightlyBuildTag}" "${releaseBuildTag}"
  docker tag "${nightlyBuildTag}" "${releaseBuildTagPrivate}"
  docker tag "${nightlyBuildTag}" "${latestBuildTag}"
  docker tag "${nightlyBuildTag}" "${latestBuildTagPrivate}"

  docker push "${releaseBuildTag}"
  docker push "${latestBuildTag}"
fi
