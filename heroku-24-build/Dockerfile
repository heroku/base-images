FROM heroku/heroku:24
COPY setup.sh /tmp/setup.sh
USER root
RUN /tmp/setup.sh

ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
USER 1000

ENV CNB_STACK_ID "heroku-24"
LABEL io.buildpacks.stack.id="heroku-24"
