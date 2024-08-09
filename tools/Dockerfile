# This Docker image is used only for local testing and not by the CI-based releases.
# See BUILD.md for usage instructions.
FROM ubuntu:24.04

RUN apt-get update --error-on=any \
  && apt-get install -y --no-install-recommends docker.io jq curl

COPY bin /usr/local/bin

VOLUME ["/var/run/docker.sock"]
ENTRYPOINT ["/usr/local/bin/convert-to-heroku-stack-image"]
