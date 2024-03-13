# Building Heroku Base Images Locally

## Prepare your local environment

The build scripts in this repository require bash 4+. To update to newer bash on OS X, see:
https://johndjameson.com/blog/updating-your-shell-with-homebrew/

## Adding packages to the base image

Add the package you want to the appropriate `setup.sh` for example `heroku-22/setup.sh`:

```diff
+    libc6-dev \
```

Once done, run the `bin/build.sh` locally to generate the corresponding `installed-packages.txt`.

The `*-build` variants include all the packages from the non-build variant by default. This means that if you're adding a package to both, you only need to add them to the non-build variant. The example above will add `libc6-dev` to both `heroku-22` and `heroku-22-build`.

The `*cnb*` variants inherit the installed packages from the non-`*cnb*` variant. Add packages to a non-`*cnb*` variant to add them to the `*cnb*` variant.

## Build

To build the base images locally, run this from the repo root:

    bin/build.sh STACK_VERSION

For example:

    ./bin/build.sh 22

If you're building on a machine with an architecture other than amd64, set `DOCKER_DEFAULT_PLATFORM` to the appropriate "`linux/amd64`" value in the environment:

    DOCKER_DEFAULT_PLATFORM=linux/amd64 ./bin/build.sh 22

The supported stacks are: `20` and `22`. This script will build a family
of 4 images:

* `heroku/heroku:{STACK_VERSION}` - The base run image for the Heroku platform
* `heroku/heroku:{STACK_VERSION}-build` - The base build image for the Heroku platform
* `heroku/heroku:{STACK_VERSION}-cnb` - The base run image for Cloud Native Buildpacks
* `heroku/heroku:{STACK_VERSION}-cnb-build` - The base build image for Cloud Native Buildpacks

# Releasing Heroku Base Images

We use GitHub Actions to build and release Heroku Base Images:

* Any push to `main` will build the images and push the nightly Docker tag variants (such as `heroku/heroku:22-build.nightly`).
* Any new Git tag will build the image and push the latest Docker tag (such as `heroku/heroku:22-build`),
  as well as a versioned tag (such as `heroku/heroku:22-build.v123`). The Docker image will then also be
  converted to a Heroku-specific `.img` format and uploaded to S3 for consumption by the runtime hosts.

# Generating `.img` format Base Images locally

To test the generation of the Heroku-specific `.img` file:

1. Build the Docker images for your chosen stack as normal above.
2. `docker build --platform=linux/amd64 ./tools -t heroku-image-tools`
3. `docker run -it --rm --platform=linux/amd64 --privileged -v /var/run/docker.sock:/var/run/docker.sock heroku-image-tools STACK` (where `STACK` is the full stack name like `heroku-22`)
