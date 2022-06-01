FROM heroku/heroku:20

RUN ln -s /workspace /app

RUN groupadd heroku --gid 1000 && \
  useradd heroku -u 1000 -g 1000 -s /bin/bash -m

LABEL io.buildpacks.stack.id="heroku-20"
USER heroku
ENV HOME /app
