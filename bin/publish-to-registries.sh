#!/usr/bin/env bash

set -euo pipefail
set -x


bin/build.sh "${STACK_VERSION}"

# Disable tracing temporarily to prevent logging registry tokens.
(set +x; echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin)
(set +x; curl -f -X POST "$SERVICE_TOKEN_ENDPOINT" -d "{\"username\":\"$SERVICE_USERNAME\",\"password\":\"$SERVICE_PASSWORD\"}" -s --retry 3 | jq -r ".raw_id_token" | docker login "$INTERNAL_REGISTRY_HOST" -u "$INTERNAL_REGISTRY_USERNAME" --password-stdin)

push_group() {
    local targetTagBase="$1"
    local targetTagSuffix="$2"
    for variant in "" "-build" "-cnb" "-cnb-build"; do
      source="${publicTag}${variant}"
      target="${targetTagBase}${variant}${targetTagSuffix}"
      docker tag "${source}" "${target}"
      docker push "${target}"
    done
}

date=$(date -u '+%Y-%m-%d-%H.%M.%S')
publicTag="heroku/heroku:${STACK_VERSION}"
privateTag="heroku/heroku-private:${STACK_VERSION}"
internalTag="${INTERNAL_REGISTRY_HOST}/s/${SERVICE_USERNAME}/heroku:${STACK_VERSION}"

# Push nightly tags to dockerhub (e.g. heroku/heroku:22.nightly)
push_group "${publicTag}" ".nightly"

# Push date tags to private dockerhub (e.g. heroku/heroku-private:22.2022-06-01-17.00.00)
push_group "${privateTag}" ".${date}"

if [[ -v CIRCLE_TAG ]]; then
  # Push release tags to dockerhub (e.g. heroku/heroku:22.v99)
  push_group "${publicTag}" ".${CIRCLE_TAG}"

  # Push release tags to internal registry
  push_group "${internalTag}" ".${CIRCLE_TAG}"

  # Push latest/no-suffix tags to dockerhub (e.g. heroku/heroku:22)
  push_group "${publicTag}" ""

  # Push latest/no-suffix tags to internal registry
  push_group "${internalTag}" ""
fi
