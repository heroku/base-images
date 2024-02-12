FROM ubuntu:24.04
COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh

# https://github.com/buildpacks/spec/blob/main/platform.md#run-image
USER 1000
LABEL io.buildpacks.stack.id="heroku-24"
