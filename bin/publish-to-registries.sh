#!/usr/bin/env bash

set -euo pipefail
set -x

bin/build.sh "${STACK_VERSION}"

(
  # Disable tracing (until the end of this subshell) to prevent logging registry tokens.
  set +x

  echo "Logging into Docker Hub..."
  echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin
)

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

publicTag="heroku/heroku:${STACK_VERSION}"

# Push nightly tags to Docker Hub (e.g. heroku/heroku:22.nightly)
push_group "${publicTag}" ".nightly"

if [ "$GITHUB_REF_TYPE" == 'tag' ]; then
  # Push release tags to Docker Hub (e.g. heroku/heroku:22.v99)
  push_group "${publicTag}" ".${GITHUB_REF_NAME}"

  # Push latest/no-suffix tags to Docker Hub (e.g. heroku/heroku:22)
  push_group "${publicTag}" ""
fi
