FROM heroku/heroku:20-build

RUN groupadd heroku --gid 1000 && \
  useradd heroku -u 1000 -g 1000 -s /bin/bash -m

RUN mkdir /app && \
  chown heroku:heroku /app

ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000

ENV CNB_STACK_ID "heroku-20"
LABEL io.buildpacks.stack.id="heroku-20"

USER heroku
