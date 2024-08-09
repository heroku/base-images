#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
. bin/stack-helpers.sh

STACK_VERSION="${1:-"NAN"}"
[[ $STACK_VERSION =~ ^[0-9]+$ ]] || (abort "fatal: invalid STACK_VERSION")

GIT_REF="${2:-}"
[[ $GIT_REF =~ ^[a-f0-9]+$ ]] || (abort "fatal: invalid GIT_REF")

for STACK in "heroku-${STACK_VERSION}" "heroku-${STACK_VERSION}-build"; do
    IMG_PATH=$(find /tmp/ -type d -regex ".*/${STACK}-[a-f0-9]*$")
    IMG_VERSION=${IMG_PATH##*-}
    IMG_GZ="${IMG_PATH}.img.gz"
    IMG_PKG_VERSIONS="${IMG_PATH}.pkg.versions"
    IMG_SHA256="${IMG_PATH}.img.sha256"
    IMG_MANIFEST="${IMG_PATH}.manifest"

    display "Creating image on ${MANIFEST_APP_URL}"

    jq \
        --null-input \
        --arg stack "$STACK" \
        --slurpfile packages "${IMG_PKG_VERSIONS}" \
        --arg version "$IMG_VERSION" \
        --arg git_ref "$GIT_REF" \
        --arg sha "$(< "$IMG_SHA256")" \
        '{
            stack: $stack,
            version: $version,
            git_ref: $git_ref,
            sha: $sha,
            packages: $packages
        }' |
        curl \
            --silent --show-error --fail \
            --user-agent 'Base Image Tools' \
            --header "Authorization: Bearer $MANIFEST_APP_TOKEN" \
            --header "Content-Type: application/json" \
            --data @- \
            "$MANIFEST_APP_URL/images" |
        jq > "${IMG_MANIFEST}" \
            --arg name "$STACK" \
            '{
                name: $name
            } + .'

    display "Uploading image to S3"
    PUT_URL=$(jq -r .put_url "$IMG_MANIFEST")
    curl \
        --silent --show-error \
        --user-agent 'Base Image Tools' \
        --header "Content-Type: application/octet-stream" \
        --upload-file "$IMG_GZ" \
        "$PUT_URL"
done

display "Publishing manifest update"

jq --null-input --exit-status \
    '[inputs]
    | map({
        name: .name,
        image_id: .id
    }) | {stacks: .}' \
    /tmp/*.manifest \
| curl \
    --fail --user-agent 'Base Image Tools' \
    --header "Authorization: Bearer $MANIFEST_APP_TOKEN" \
    --header "Content-Type: application/json" \
    --request PATCH \
    --data @- \
    "$MANIFEST_APP_URL/manifest/staging"
