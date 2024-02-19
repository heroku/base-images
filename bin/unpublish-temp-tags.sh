#!/usr/bin/env bash

set -euo pipefail
set -x

unpublish_group() {
    local tagBase="$1"
    local targetTagSuffix="$2"
    variants=("" "-build")
    if (( STACK_VERSION <= 22 )); then
        variants+=("-cnb" "-cnb-build")
    fi
    for variant in "${variants[@]}"; do
      hub-tool tag rm "${tagBase}${variant}${targetTagSuffix}"
    done
}

publicTag="heroku/heroku:${STACK_VERSION}"
tempTagSuffix=".temp_${GITHUB_RUN_ID}"

unpublish_group "${publicTag}" "${tempTagSuffix}"
