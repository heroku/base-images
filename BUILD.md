# Building Heroku Base Images Locally

## Prepare your local environment

The build scripts in this repository require:

- bash 4+. To update to newer bash on OS X, see: https://johndjameson.com/blog/updating-your-shell-with-homebrew/
- Docker Desktop. To build multi-arch images (heroku-24 and beyond),
  the `containerd` snapshotter feature should be enabled.

## Build

To build the base images locally, run this from the repo root:

    bin/build.sh STACK_VERSION

For example:

    ./bin/build.sh 24

## Adding packages to the base image

Add the package you want to the appropriate `setup.sh` for example `heroku-24/setup.sh`:

```diff
+    libc6-dev
```

Once done, run `bin/build.sh` locally to generate the corresponding `installed-packages*` files. Multi-arch base images (heroku-24 and beyond) will produce an `installed-packages-$ARCH.txt` for each architecture, while single architecture images will produce a singular `installed-packages.txt`.

The `*-build` variants include all the packages from the non-build variant by default. This means that if you're adding a package to both, you only need to add them to the non-build variant. The example above will add `libc6-dev` to both `heroku-24` and `heroku-24-build`.

The `*cnb*` variants (which only exist for heroku-22 and prior) inherit the installed packages from the non-`*cnb*` variant. Add packages to a non-`*cnb*` variant to add them to the `*cnb*` variant.

# Releasing Heroku Base Images

We use GitHub Actions to build and release Heroku Base Images:

* Any push to `main` will build the images and push the nightly Docker tag variants (such as `heroku/heroku:24-build.nightly`).
* Any new Git tag will build the image and push the latest Docker tag (such as `heroku/heroku:24-build`),
  as well as a versioned tag (such as `heroku/heroku:24-build.v123`). The `arm64` images will then also be
  converted to a Heroku-specific `.img` format and uploaded to S3 for consumption by the runtime hosts.

# Generating `.img` format Base Images locally

To test the generation of the Heroku-specific, amd64-only `.img` file:

1. Build the Docker images for your chosen stack as normal above.
2. `docker build --platform=linux/amd64 ./tools -t heroku-image-tools`
3. `docker run -it --rm --platform=linux/amd64 --privileged -v /var/run/docker.sock:/var/run/docker.sock heroku-image-tools STACK_VERSION` (where `STACK_VERSION` is a integer version like `24`)
