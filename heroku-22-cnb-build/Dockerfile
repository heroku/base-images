ARG BASE_IMAGE=heroku/heroku:22-build
FROM $BASE_IMAGE

RUN groupadd heroku --gid 1000 && \
  useradd heroku -u 1000 -g 1000 -s /bin/bash -m

RUN mkdir /app && \
  chown heroku:heroku /app

ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
ENV CNB_STACK_ID "heroku-22"
ENV CNB_TARGET_OS="linux"
ENV CNB_TARGET_ARCH="amd64"

LABEL io.buildpacks.stack.id="heroku-22"

USER heroku
