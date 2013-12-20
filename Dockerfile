FROM heroku/ubuntu:lucid
MAINTAINER Fabio Kung <fabio@heroku.com>

ADD bin/cedar.sh /tmp/build.sh
RUN /tmp/build.sh
RUN ["bash", "-c", "mkdir", "-p", "/{app,tmp,proc,dev,var,var/log,var/tmp,home/group_home}"]
RUN chmod 755 /home/group_home
RUN echo "export PS1='\\[\\033[01;34m\\]\\w\\[\\033[00m\\] \\[\\033[01;32m\\]$ \\[\\033[00m\\]'" > /etc/bash.bashrc
RUN rm -f /tmp/cedar.sh
