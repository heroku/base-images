FROM heroku/heroku:16
COPY ./bin/heroku-16-build.sh /tmp/build.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/build.sh \
  && rm -rf /var/lib/apt/lists/*
