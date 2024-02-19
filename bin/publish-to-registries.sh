#!/usr/bin/env bash

set -euo pipefail
set -x

(
  # Disable tracing (until the end of this subshell) to prevent logging registry tokens.
  set +x

  echo "Logging into Docker Hub..."
  echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin
)

push_group() {
    local tagBase="$1"
    local sourceTagSuffix="$2"
    local targetTagSuffix="$3"
    variants=("" "-build")
    if (( STACK_VERSION <= 22 )); then
        variants+=("-cnb" "-cnb-build")
    fi
    for variant in "${variants[@]}"; do
      source="${tagBase}${variant}${sourceTagSuffix}"
      target="${tagBase}${variant}${targetTagSuffix}"
      docker tag "${source}" "${target}"
      docker push "${target}"
    done
}

tempTagSuffix=".temp_${GITHUB_RUN_ID}"
# build+push to a temporary tag (e.g. heroku/heroku:22.temp_12345678)
bin/build.sh "${STACK_VERSION}" "${tempTagSuffix}"

publicTag="heroku/heroku:${STACK_VERSION}"

# Push nightly tags to Docker Hub (e.g. heroku/heroku:22.nightly)
push_group "${publicTag}" "${tempTagSuffix}" ".nightly"

if [[ "$GITHUB_REF_TYPE" == 'tag' ]]; then
  # Push release tags to Docker Hub (e.g. heroku/heroku:22.v99)
  push_group "${publicTag}" "${tempTagSuffix}" ".${GITHUB_REF_NAME}"

  # Push latest/no-suffix tags to Docker Hub (e.g. heroku/heroku:22)
  push_group "${publicTag}" "${tempTagSuffix}" ""
fi
