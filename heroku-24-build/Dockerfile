ARG BASE_IMAGE=heroku/heroku:24
FROM $BASE_IMAGE
COPY setup.sh /tmp/setup.sh
USER root
RUN /tmp/setup.sh

USER 1000
ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
ENV CNB_STACK_ID "heroku-24"
LABEL io.buildpacks.stack.id="heroku-24"
