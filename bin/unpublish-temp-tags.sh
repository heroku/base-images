#!/usr/bin/env bash

set -euo pipefail
set -x

dockerhub_token=$(curl -s -f -H "Content-Type: application/json" -X POST -d "{\"username\": \"${DOCKER_HUB_USERNAME}\", \"password\": \"${DOCKER_HUB_TOKEN}\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)

unpublish_group() {
    local stackVersion="$1"
    local targetTagSuffix="$2"
    variants=("" "-build")
    if (( stackVersion <= 22 )); then
        variants+=("-cnb" "-cnb-build")
    fi
    for variant in "${variants[@]}"; do
      echo "Deleting heroku/heroku:${stackVersion}${variant}${targetTagSuffix}"
      code=$(curl -s -f -X DELETE -H "Authorization: JWT ${dockerhub_token}" --write-out "%{http_code}"
      "https://hub.docker.com/v2/repositories/heroku/heroku/tags/${stackVersion}${variant}${targetTagSuffix}/")

      if (( code != 404 )) || (( code != 200 )) || (( code != 201 )); then
          echo "Couldn't delete heroku/heroku:${stackVersion}${variant}${targetTagSuffix}: ${code}"
      fi
    done
}

stackVersion="${1:-$STACK_VERSION}"
tempTagSuffix="${2:-".temp_$GITHUB_RUN_ID"}"
# delete each tag in a group on Docker Hub.
unpublish_group "${stackVersion}" "${tempTagSuffix}"
