#!/bin/sh

set -ex

tag="${IMAGE_TAG}.nightly"

./docker-build.sh $STACK $TAG

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

docker push $TAG

if [ "$STACK" = "cedar-14" ]; then
  docker tag $TAG herokutest/cedar:latest
  docker push herokutest/cedar:latest
fi
