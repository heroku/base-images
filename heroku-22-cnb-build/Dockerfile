FROM heroku/heroku:22-build

ARG pack_uid=1000
ARG pack_gid=1000

RUN groupadd heroku --gid ${pack_gid} && \
  useradd heroku -u ${pack_uid} -g ${pack_gid} -s /bin/bash -m
RUN mkdir /app && \
  chown heroku:heroku /app

ENV CNB_USER_ID=${pack_uid}
ENV CNB_GROUP_ID=${pack_gid}

ARG STACK="heroku-22"
ENV STACK "${STACK}"
ENV CNB_STACK_ID "${STACK}"
LABEL io.buildpacks.stack.id="${STACK}"

USER heroku
