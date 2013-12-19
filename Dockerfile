FROM heroku/ubuntu:lucid
MAINTAINER Fabio Kung <fabio@heroku.com>

ADD bin/cedar.sh /tmp/build.sh
RUN /tmp/build.sh
RUN rm -f /tmp/cedar.sh
