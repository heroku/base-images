ARG BASE_IMAGE=heroku/heroku:22-build
FROM $BASE_IMAGE

RUN groupadd heroku --gid 1000 && \
  useradd heroku -u 1000 -g 1000 -s /bin/bash -m

RUN mkdir /app && \
  chown heroku:heroku /app

# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#build-image
ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
# Note: This image doesn't inherit from the CNB run image variant so we have
# to redeclare the labels present in the CNB run image again here.
LABEL io.buildpacks.base.distro.name="ubuntu"
LABEL io.buildpacks.base.distro.version="22.04"
LABEL io.buildpacks.base.homepage="https://github.com/heroku/base-images"
LABEL io.buildpacks.base.maintainer="Heroku"

# Stack IDs are deprecated, but we still set these for backwards compatibility:
# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#iobuildpacksstack-labels
ENV CNB_STACK_ID "heroku-22"
LABEL io.buildpacks.stack.id="heroku-22"

USER heroku
