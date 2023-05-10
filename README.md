## Heroku Stack Images

[![CI](https://github.com/heroku/stack-images/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/stack-images/actions/workflows/ci.yml)

This repository holds recipes for building [Heroku stack images](https://devcenter.heroku.com/articles/stack).
The recipes are also rendered into Docker images that are available on Docker Hub:

| Image                                     | Base                                  | Type                       | Status      |
|-------------------------------------------|---------------------------------------|----------------------------|-------------|
| [heroku/heroku:18][heroku-tags]           | [ubuntu:18.04][ubuntu-tags]           | Heroku Runtime Stack Image | End-of-life |
| [heroku/heroku:18-build][heroku-tags]     | [heroku/heroku:18][heroku-tags]       | Heroku Build Stack Image   | End-of-life |
| [heroku/heroku:18-cnb][heroku-tags]       | [heroku/heroku:18][heroku-tags]       | CNB Runtime Stack Image    | End-of-life |
| [heroku/heroku:18-cnb-build][heroku-tags] | [heroku/heroku:18-build][heroku-tags] | CNB Build Stack Image      | End-of-life |
| [heroku/heroku:20][heroku-tags]           | [ubuntu:20.04][ubuntu-tags]           | Heroku Runtime Stack Image | Available   |
| [heroku/heroku:20-build][heroku-tags]     | [heroku/heroku:20][heroku-tags]       | Heroku Build Stack Image   | Available   |
| [heroku/heroku:20-cnb][heroku-tags]       | [heroku/heroku:20][heroku-tags]       | CNB Runtime Stack Image    | Available   |
| [heroku/heroku:20-cnb-build][heroku-tags] | [heroku/heroku:20-build][heroku-tags] | CNB Build Stack Image      | Available   |
| [heroku/heroku:22][heroku-tags]           | [ubuntu:22.04][ubuntu-tags]           | Heroku Runtime Stack Image | Recommended |
| [heroku/heroku:22-build][heroku-tags]     | [heroku/heroku:22][heroku-tags]       | Heroku Build Stack Image   | Recommended |
| [heroku/heroku:22-cnb][heroku-tags]       | [heroku/heroku:22][heroku-tags]       | CNB Runtime Stack Image    | Recommended |
| [heroku/heroku:22-cnb-build][heroku-tags] | [heroku/heroku:22-build][heroku-tags] | CNB Build Stack Image      | Recommended |

### Learn more

* [Lists of packages installed on current stacks](https://devcenter.heroku.com/articles/stack-packages)
* [Stack update policy](https://devcenter.heroku.com/articles/stack-update-policy)

See [BUILD.md](BUILD.md) for instructions on how to build the images yourself.

[heroku-tags]: https://hub.docker.com/r/heroku/heroku/tags
[ubuntu-tags]: https://hub.docker.com/_/ubuntu?tab=tags
