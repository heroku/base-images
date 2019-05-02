## Heroku Stack Images

[![Build Status](https://travis-ci.org/heroku/stack-images.svg?branch=master)](https://travis-ci.org/heroku/stack-images)

This repository holds recipes for building [Heroku stack images](https://devcenter.heroku.com/articles/stack).  The recipes are also rendered into Docker images that are available on Docker Hub:

* [Heroku-16/Heroku-18 Docker image](https://registry.hub.docker.com/u/heroku/heroku/)

Note: The [Cedar-14 Docker image](https://registry.hub.docker.com/u/heroku/cedar/) is no longer being updated,
since the Ubuntu ESM agreement requires that the updates we receive from Canonical are not published publicly.

### Learn more

* [Lists of packages installed on current stacks](https://devcenter.heroku.com/articles/stack-packages)
* [Stack update policy](https://devcenter.heroku.com/articles/stack-update-policy)

See [BUILD.md](BUILD.md) for instructions on how to build the images yourself.
