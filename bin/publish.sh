#!/bin/sh

set -ex

nightlyTag="${IMAGE_TAG}.nightly"
nightlyBuildTag="${IMAGE_TAG}-build.nightly"

./docker-build.sh $STACK $nightlyTag $nightlyBuildTag

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

docker push $nightlyTag
if [ "$STACK" != "cedar-14" ]; then
  docker push $nightlyBuildTag
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
