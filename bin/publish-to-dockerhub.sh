#!/bin/sh

set -ex

if [ "${STACK}" = 'cedar-14' ]; then
  echo 'Error: Publishing cedar-14 images to Docker Hub is no longer permitted, since they contain ESM updates.'
  exit 1
fi

nightlyTag="${IMAGE_TAG}.nightly"
nightlyBuildTag="${IMAGE_TAG}-build.nightly"
date=`date -u '+%Y-%m-%d-%H.%M.%S'`
dateTag="${PRIVATE_IMAGE_TAG}.${date}"
dateBuildTag="${PRIVATE_IMAGE_TAG}-build.${date}"

bin/build.sh $STACK $nightlyTag $nightlyBuildTag

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

docker push $nightlyTag

docker tag $nightlyTag $dateTag
docker push $dateTag

if [ "$STACK" != "cedar-14" ]; then
  docker push $nightlyBuildTag

  docker tag $nightlyBuildTag $dateBuildTag
  docker push $dateBuildTag
fi

if [ -n "$TRAVIS_TAG" ]; then
  releaseTag="${IMAGE_TAG}.${TRAVIS_TAG}"
  releaseBuildTag="${IMAGE_TAG}-build.${TRAVIS_TAG}"
  latestTag="${IMAGE_TAG}"
  latestBuildTag="${IMAGE_TAG}-build"

  docker tag $nightlyTag $releaseTag
  docker tag $nightlyTag $latestTag

  docker push $releaseTag
  docker push $latestTag

  if [ "$STACK" != "cedar-14" ]; then
    docker tag $nightlyBuildTag $releaseBuildTag
    docker tag $nightlyBuildTag $latestBuildTag

    docker push $releaseBuildTag
    docker push $latestBuildTag
  else
    docker tag $nightlyTag heroku/cedar:latest
    docker push heroku/cedar:latest
  fi
fi
