#!/bin/sh

set -ex

nightlyTag="${IMAGE_TAG}.nightly"

./docker-build.sh $STACK $nightlyTag

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

docker push $nightlyTag

if [ -n "$TRAVIS_TAG" ]; then
  releaseTag="${IMAGE_TAG}.${TRAVIS_TAG}"
  latestTag="${IMAGE_TAG}"

  docker tag $nightlyTag $releaseTag
  docker tag $nightlyTag $latestTag

  docker push $releaseTag
  docker push $latestTag

  if [ "$STACK" = "cedar-14" ]; then
    docker tag $nightlyTag heroku/cedar:latest
    docker push heroku/cedar:latest
  fi
fi
