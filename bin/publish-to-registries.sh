#!/usr/bin/env bash

set -euo pipefail
set -x

(
  # Disable tracing (until the end of this subshell) to prevent logging registry tokens.
  set +x

  echo "Logging into Docker Hub..."
  echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin

  echo "Logging into internal container registry..."
  curl -sSf --retry 3 -X POST "$ID_SERVICE_TOKEN_ENDPOINT" -d "{\"username\":\"${ID_SERVICE_USERNAME}\",\"password\":\"${ID_SERVICE_PASSWORD}\"}" \
    | jq -er ".raw_id_token" \
    | docker login "$INTERNAL_REGISTRY_HOST" -u "$INTERNAL_REGISTRY_USERNAME" --password-stdin
)

bin/build.sh "${STACK_VERSION}"

push_group() {
    local targetTagBase="$1"
    local targetTagSuffix="$2"
    for variant in "" "-build" "-cnb" "-cnb-build"; do
      source="${publicTag}${variant}"
      target="${targetTagBase}${variant}${targetTagSuffix}"
      chmod +r "$HOME"/.docker/config.json
      docker container run --rm --net host \
        -v regctl-conf:/home/appuser/.regctl/ \
        -v "$HOME"/.docker/config.json:/home/appuser/.docker/config.json \
        regclient/regctl image copy "${source}" "${target}"
    done
}

date=$(date -u '+%Y-%m-%d-%H.%M.%S')
publicTag="heroku/heroku:${STACK_VERSION}"
privateTag="heroku/heroku-private:${STACK_VERSION}"
internalTag="${INTERNAL_REGISTRY_HOST}/s/${ID_SERVICE_USERNAME}/heroku:${STACK_VERSION}"

# Push nightly tags to dockerhub (e.g. heroku/heroku:22.nightly)
push_group "${publicTag}" ".nightly"

# Push date tags to private dockerhub (e.g. heroku/heroku-private:22.2022-06-01-17.00.00)
push_group "${privateTag}" ".${date}"

if [ "$GITHUB_REF_TYPE" == 'tag' ]; then
  # Push release tags to dockerhub (e.g. heroku/heroku:22.v99)
  push_group "${publicTag}" ".${GITHUB_REF_NAME}"

  # Push release tags to internal registry
  push_group "${internalTag}" ".${GITHUB_REF_NAME}"

  # Push latest/no-suffix tags to dockerhub (e.g. heroku/heroku:22)
  push_group "${publicTag}" ""

  # Push latest/no-suffix tags to internal registry
  push_group "${internalTag}" ""
fi
