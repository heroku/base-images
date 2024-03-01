ARG BASE_IMAGE=heroku/heroku:24
FROM $BASE_IMAGE
USER root
RUN --mount=target=/build /build/setup.sh

# https://github.com/buildpacks/spec/blob/main/platform.md#build-image
USER 1002
ENV CNB_USER_ID=1002
ENV CNB_GROUP_ID=1000
ENV CNB_STACK_ID "heroku-24"
ENV CNB_TARGET_OS="linux"
ENV CNB_TARGET_ARCH="amd64"
