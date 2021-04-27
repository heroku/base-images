# This Docker image is used only for local testing and not by the CI-based releases.
FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install docker.io -y
RUN apt-get install jq -y
RUN apt-get install curl -y

COPY bin /usr/local/bin

VOLUME ["/var/run/docker.sock"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
