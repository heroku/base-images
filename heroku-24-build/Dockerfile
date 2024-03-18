ARG BASE_IMAGE=heroku/heroku:24
FROM $BASE_IMAGE
USER root
RUN --mount=target=/build /build/setup.sh

# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#build-image
# The `io.buildpacks.base.*` labels are inherited from the run image, so don't need to be repeated here.
USER 1002
ENV CNB_USER_ID=1002
ENV CNB_GROUP_ID=1000

# Stack IDs are deprecated, but we still set this for backwards compatibility:
# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#iobuildpacksstack-labels
ENV CNB_STACK_ID "heroku-24"
