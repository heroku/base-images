# Building Stack Images Locally

## Prepare your local environment

The build scripts in this repository require bash 4+. To update to newer bash on OS X, see:
https://johndjameson.com/blog/updating-your-shell-with-homebrew/

## Adding packages to the stack image

Add the package you want to the appropriate `setup.sh` for example `heroku-18/setup.sh`:

```diff
+    libc6-dev \
```

Once done, run the `bin/build.sh` locally to generate the corresponding `installed-packages.txt`.

The `*-build` variants include all the packages from the non-build variant by default. This means that if you're adding a package to both, you only need to add them to the non-build variant. The example above will add `libc6-dev` to both `heroku-18` and `heroku-18-build`.

The `*cnb*` variants inherit the installed packages from the non-`*cnb*` variant. Add packages to a non-`*cnb*` variant to add them to the `*cnb*` variant.

## Build

To build the stack images locally, run this from the repo root:

    bin/build.sh STACK_VERSION

For example:

    ./bin/build.sh 22

If you're building on a machine with an architecture other than amd64, set `DOCKER_DEFAULT_PLATFORM` to the appropriate "`linux/amd64`" value in the environment:

    DOCKER_DEFAULT_PLATFORM=linux/amd64 ./bin/build.sh 22

The supported stacks are: `18`, `20`, and `22`. This script will build a family
of 4 images:

* `heroku/heroku:{STACK_VERSION}` - The runtime stack image for the Heroku platform
* `heroku/heroku:{STACK_VERSION}-build` - The build-time stack image for the Heroku platform
* `heroku/heroku:{STACK_VERSION}-cnb` - The runtime stack image for Cloud Native Buildpacks
* `heroku/heroku:{STACK_VERSION}-cnb-build` - The build-time stack image for Cloud Native Buildpacks

# Releasing Stack Images

We use GitHub Actions to build and release Stack Images:

* Any push to `main` will build the images and push the nightly Docker tag variants (such as `heroku/heroku:22-build.nightly`).
* Any new Git tag will build the image and push the latest Docker tag (such as `heroku/heroku:22-build`), as well as a versioned tag (such as `heroku/heroku:22-build.v89`).

# Releasing Heroku Stack Images Locally (Prime)

When building Heroku Stack Images for release locally, youll need a number of additional steps.

NOTE: These steps do *not* apply to `*cnb*` images.

    export DOCKER_DEFAULT_PLATFORM=linux/amd64
    # Build the stack image(s) as you would above
    # …
    cd stack-images/tools
    # build the stack-image-tooling
    docker build . -t heroku/stack-image-tools
    # SET MANIFEST_APP_URL and MANIFEST_APP_TOKEN values, this is the app that controls the bucket for images and metadata about the images (Cheverny)
    docker run -it --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -e "MANIFEST_APP_URL=$MANIFEST_APP_URL" -e "MANIFEST_APP_TOKEN=$MANIFEST_APP_TOKEN" heroku/stack-image-tools STACK
    # this will use your local docker image and convert it to a heroku stack image
    # it will then upload this image and the staging manifest via the MANIFEST_APP
