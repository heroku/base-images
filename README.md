## Heroku Base Images

[![CI](https://github.com/heroku/base-images/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/base-images/actions/workflows/ci.yml)

This repository holds recipes for building the base images for [Heroku stacks](https://devcenter.heroku.com/articles/stack).
The recipes are also rendered into Docker images that are available on Docker Hub:

| Image                                     | Type                   | OS           | Supported Architectures | Default `USER` | Status       |
|-------------------------------------------|------------------------|--------------|-------------------------|----------------| -------------|
| [heroku/heroku:20][heroku-tags]           | Heroku Run Image       | Ubuntu 20.04 | AMD64                   | `root`         |  Available   |
| [heroku/heroku:20-build][heroku-tags]     | Heroku Build Image     | Ubuntu 20.04 | AMD64                   | `root`         |  Available   |
| [heroku/heroku:20-cnb][heroku-tags]       | CNB Run Image          | Ubuntu 20.04 | AMD64                   | `heroku`       |  Available   |
| [heroku/heroku:20-cnb-build][heroku-tags] | CNB Build Image        | Ubuntu 20.04 | AMD64                   | `heroku`       |  Available   |
| [heroku/heroku:22][heroku-tags]           | Heroku Run Image       | Ubuntu 22.04 | AMD64                   | `root`         |  Available   |
| [heroku/heroku:22-build][heroku-tags]     | Heroku Build Image     | Ubuntu 22.04 | AMD64                   | `root`         |  Available   |
| [heroku/heroku:22-cnb][heroku-tags]       | CNB Run Image          | Ubuntu 22.04 | AMD64                   | `heroku`       |  Available   |
| [heroku/heroku:22-cnb-build][heroku-tags] | CNB Build Image        | Ubuntu 22.04 | AMD64                   | `heroku`       |  Available   |
| [heroku/heroku:24][heroku-tags]           | Heroku/CNB Run Image   | Ubuntu 24.04 | AMD64 + ARM64           | `heroku`       |  Recommended |
| [heroku/heroku:24-build][heroku-tags]     | Heroku/CNB Build Image | Ubuntu 24.04 | AMD64 + ARM64           | `heroku`       |  Recommended |

The build image variants use the run images as their base, but include additional packages needed
at build time such as development headers and compilation toolchains.

The CNB image variants contain additional metadata and changes required to make them compatible with
Heroku's Cloud Native Buildpacks [builder images](https://github.com/heroku/cnb-builder-images).

For images where the default `USER` is `heroku`, you will need to switch back to the `root` user when
modifying locations other then `/home/heroku` and `/tmp`. You can do this by adding `USER root` to
your `Dockerfile` when building images, or by passing `--user root` to any `docker run` invocations.

### Learn more

* [Lists of packages installed on current Heroku stacks](https://devcenter.heroku.com/articles/stack-packages)
* [Stack update policy](https://devcenter.heroku.com/articles/stack-update-policy)

See [BUILD.md](BUILD.md) for instructions on how to build the images yourself.

[heroku-tags]: https://hub.docker.com/r/heroku/heroku/tags
[ubuntu-tags]: https://hub.docker.com/_/ubuntu?tab=tags
