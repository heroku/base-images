#!/usr/bin/env bash

set -euo pipefail

dockerhub_token=$(curl -sS -f --retry 3 --retry-connrefused --connect-timeout 5 --max-time 30 -H "Content-Type: application/json" -X POST -d "{\"username\": \"${DOCKER_HUB_USERNAME}\", \"password\": \"${DOCKER_HUB_TOKEN}\"}" https://hub.docker.com/v2/users/login/ | jq --exit-status -r .token)

unpublish_group() {
    local stackVersion="$1"
    local targetTagSuffix="$2"
    local status=0
    variants=("" "-build")
    if (( stackVersion <= 22 )); then
        variants+=("-cnb" "-cnb-build")
    fi
    for variant in "${variants[@]}"; do
      echo "Deleting heroku/heroku:${stackVersion}${variant}${targetTagSuffix}"
        response=$(curl -s -X DELETE \
            -H "Authorization: JWT ${dockerhub_token}" \
            "https://hub.docker.com/v2/namespaces/heroku/repositories/heroku/tags/${stackVersion}${variant}${targetTagSuffix}"
        )

      if [[ -z $response ]]; then
          >&2 echo "Deleted."
      elif [[ $response =~ "tag not found" ]]; then
          >&2 echo "Tag does not exist."
      else
          >&2 echo "Couldn't delete. Response: ${response}"
          status=22
      fi
    done
    return $status
}

stackVersion="${1:-$STACK_VERSION}"
tempTagSuffix="${2:-".temp-$GITHUB_RUN_ID"}"
# delete each tag in a group on Docker Hub.
unpublish_group "${stackVersion}" "${tempTagSuffix}"
