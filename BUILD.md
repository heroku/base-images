# Building Stack Images Locally

To build the stack images locally, run this from the repo root:

    ./docker-build.sh STACK DOCKER_TAG DOCKER_BUILD_TAG

For example:

    ./docker-build.sh heroku-18 heroku/heroku:18 heroku/heroku:18-build

The supported stacks are:

* `cedar-14`
* `heroku-16` (will also build a `heroku-16-build` image)
* `heroku-18` (will also build a `heroku-18-build` image)


# Releasing Stack Images

When building Stack Images for release, we use the Travis build system.

* Any push to master will build the images and push the `nightly` tag.
* Any new tag will build the image and push the `latest` tag, as well as one with the name of the GIT tag.
