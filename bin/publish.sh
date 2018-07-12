#!/bin/sh

set -ex

ACCOUNT=herokutest

./docker-build.sh cedar-14 $ACCOUNT/cedar:14
./docker-build.sh heroku-16 $ACCOUNT/heroku:16
./docker-build.sh heroku-18 $ACCOUNT/heroku:18

docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

docker tag $ACCOUNT/cedar:14 $ACCOUNT/cedar:latest
docker push $ACCOUNT/cedar:14
docker push $ACCOUNT/cedar:latest
docker push $ACCOUNT/heroku:16
docker push $ACCOUNT/heroku:16-build
docker push $ACCOUNT/heroku:18
docker push $ACCOUNT/heroku:18-build
