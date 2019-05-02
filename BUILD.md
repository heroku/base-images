# Building Stack Images Locally

To build the stack images locally, run this from the repo root:

    bin/build.sh STACK DOCKER_TAG DOCKER_BUILD_TAG

For example:

    bin/build.sh heroku-18 heroku/heroku:18 heroku/heroku:18-build

The supported stacks are:

* `cedar-14` (this will fail unless the Ubuntu ESM credentials are set in the local environment)
* `heroku-16` (will also build a `heroku-16-build` image)
* `heroku-18` (will also build a `heroku-18-build` image)


# Releasing Stack Images

When building Stack Images for release, we use the Travis build system.

* Any push to master will build the images and push the `nightly` tag.
* Any new tag will build the image and push the `latest` tag, as well as one with the name of the GIT tag.

# Releasing Stack Images Locally (Prime)

When building Stack Images for release locally, you'll need a number of additional steps.

    # Build the stack image(s) as you would above
    cd stack-images/tools
    # build the stack-image-tooling
    docker build . -t heroku/stack-image-tools
    # SET MANIFEST_APP_URL and MANIFEST_APP_TOKEN values, this is the app that controls the bucket for images and metadata about the images (Cheverny)
    docker run -it --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -e "MANIFEST_APP_URL=$MANIFEST_APP_URL" -e "MANIFEST_APP_TOKEN=$MANIFEST_APP_TOKEN" heroku/stack-image-tools STACK
    # this will use your local docker image and convert it to a heroku stack image
    # it will then upload this image and the staging manifest via the MANIFEST_APP
