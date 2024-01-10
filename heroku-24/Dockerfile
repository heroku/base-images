FROM ubuntu:24.04
COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh

USER 1000
ENV HOME /app
LABEL io.buildpacks.stack.id="heroku-24"
