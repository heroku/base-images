#!/usr/bin/env bash

# This script publishes a heroku base image group to Docker Hub.
# A group includes the run image, the build image, the CNB run image (for
# heroku-22 and prior), and the CNB build image (for heroku-22 and prior) for
# a specific architecture. This script assumes standard tags
# (e.g.: heroku/heroku:24 heroku/heroku:24-build) exist in the local image
# store and are images (not indicies) targeting the $arch argument.

set -euxo pipefail

baseTag="heroku/heroku"
stackVersion="$1"
arch="$2"
targetSuffix="$3"
variants=("" "-build")
platformSuffix=""
if (( stackVersion >= 24 )); then
	# heroku-24 and beyond are published as multi-arch manifest lists. All
	# platform-specific manifests must be published prior to creating the
	# manifest list.
	platformSuffix="_linux-$arch"
else
	# heroku-22 and prior have additional, specialized CNB variants to publish.
	variants+=("-cnb" "-cnb-build")
fi

for variant in "${variants[@]}"; do
	source="${baseTag}${variant}"
	target="${baseTag}${variant}${platformSuffix}${targetSuffix}"
	docker tag "${source}" "${target}"
	docker push "${target}"
done
