#!/bin/sh

set -ex

./docker-build.sh $STACK $IMAGE_TAG

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

docker push $IMAGE_TAG

if [ "$STACK" == "cedar-14" ]; then
  docker tag $IMAGE_TAG herokutest/cedar:latest
  docker push herokutest/cedar:latest
fi
