#!/usr/bin/env bash

set -euo pipefail
set -x

(
  # Disable tracing (until the end of this subshell) to prevent logging registry tokens.
  set +x

  echo "Logging into Docker Hub..."
  echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin
)

date=$(date -u '+%Y-%m-%d-%H.%M.%S')
datedTagSuffix=".${date}"
publicRepo="heroku/heroku"
privateRepo="heroku/heroku-private"
publicTag="${publicRepo}:${STACK_VERSION}"

# build+push dated tags to private dockerhub (e.g. heroku/heroku-private:22.2022-06-01-17.00.00)
bin/build.sh "${STACK_VERSION}" "${privateRepo}" "${datedTagSuffix}"

push_group() {
    local targetTagBase="$1"
    local targetTagSuffix="$2"
    variants=("" "-build")
    if [ "$STACK_VERSION" -le 22 ]; then
        variants+=("-cnb" "-cnb-build")
    fi
    for variant in "${variants[@]}"; do
      source="${privateRepo}:${STACK_VERSION}${variant}${datedTagSuffix}"
      target="${targetTagBase}${variant}${targetTagSuffix}"
      docker tag "${source}" "${target}"
      docker push "${target}"
    done
}

# Push nightly tags to Docker Hub (e.g. heroku/heroku:22.nightly)
push_group "${publicTag}" ".nightly"

if [ "$GITHUB_REF_TYPE" == 'tag' ]; then
  # Push release tags to Docker Hub (e.g. heroku/heroku:22.v99)
  push_group "${publicTag}" ".${GITHUB_REF_NAME}"

  # Push latest/no-suffix tags to Docker Hub (e.g. heroku/heroku:22)
  push_group "${publicTag}" ""
fi
