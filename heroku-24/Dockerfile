FROM ubuntu:24.04
RUN --mount=target=/build /build/setup.sh

# https://github.com/buildpacks/spec/blob/main/platform.md#run-image
USER 1000
LABEL io.buildpacks.stack.id="heroku-24"
