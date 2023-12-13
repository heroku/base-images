## Heroku Base Images

[![CI](https://github.com/heroku/base-images/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/base-images/actions/workflows/ci.yml)

This repository holds recipes for building the base images for [Heroku stacks](https://devcenter.heroku.com/articles/stack).
The recipes are also rendered into Docker images that are available on Docker Hub:

| Image                                     | Base                                  | Type                      | Status      |
|-------------------------------------------|---------------------------------------|---------------------------|-------------|
| [heroku/heroku:18][heroku-tags]           | [ubuntu:18.04][ubuntu-tags]           | Heroku Runtime Base Image | End-of-life |
| [heroku/heroku:18-build][heroku-tags]     | [heroku/heroku:18][heroku-tags]       | Heroku Build Base Image   | End-of-life |
| [heroku/heroku:18-cnb][heroku-tags]       | [heroku/heroku:18][heroku-tags]       | CNB Runtime Base Image    | End-of-life |
| [heroku/heroku:18-cnb-build][heroku-tags] | [heroku/heroku:18-build][heroku-tags] | CNB Build Base Image      | End-of-life |
| [heroku/heroku:20][heroku-tags]           | [ubuntu:20.04][ubuntu-tags]           | Heroku Runtime Base Image | Available   |
| [heroku/heroku:20-build][heroku-tags]     | [heroku/heroku:20][heroku-tags]       | Heroku Build Base Image   | Available   |
| [heroku/heroku:20-cnb][heroku-tags]       | [heroku/heroku:20][heroku-tags]       | CNB Runtime Base Image    | Available   |
| [heroku/heroku:20-cnb-build][heroku-tags] | [heroku/heroku:20-build][heroku-tags] | CNB Build Base Image      | Available   |
| [heroku/heroku:22][heroku-tags]           | [ubuntu:22.04][ubuntu-tags]           | Heroku Runtime Base Image | Recommended |
| [heroku/heroku:22-build][heroku-tags]     | [heroku/heroku:22][heroku-tags]       | Heroku Build Base Image   | Recommended |
| [heroku/heroku:22-cnb][heroku-tags]       | [heroku/heroku:22][heroku-tags]       | CNB Runtime Base Image    | Recommended |
| [heroku/heroku:22-cnb-build][heroku-tags] | [heroku/heroku:22-build][heroku-tags] | CNB Build Base Image      | Recommended |

### Learn more

* [Lists of packages installed on current Heroku stacks](https://devcenter.heroku.com/articles/stack-packages)
* [Stack update policy](https://devcenter.heroku.com/articles/stack-update-policy)

See [BUILD.md](BUILD.md) for instructions on how to build the images yourself.

[heroku-tags]: https://hub.docker.com/r/heroku/heroku/tags
[ubuntu-tags]: https://hub.docker.com/_/ubuntu?tab=tags
