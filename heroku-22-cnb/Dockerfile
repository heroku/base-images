ARG BASE_IMAGE=heroku/heroku:22
FROM $BASE_IMAGE

RUN ln -s /workspace /app

# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#run-image
USER heroku
LABEL io.buildpacks.base.distro.name="ubuntu"
LABEL io.buildpacks.base.distro.version="22.04"
LABEL io.buildpacks.base.homepage="https://github.com/heroku/base-images"
LABEL io.buildpacks.base.maintainer="Heroku"

# Stack IDs are deprecated, but we still set this for backwards compatibility:
# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#iobuildpacksstack-labels
LABEL io.buildpacks.stack.id="heroku-22"

ENV HOME=/app
