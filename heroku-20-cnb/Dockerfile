FROM heroku/heroku:20

RUN ln -s /workspace /app

ARG pack_uid=1000
ARG pack_gid=1000

RUN groupadd heroku --gid ${pack_gid} && \
  useradd heroku -u ${pack_uid} -g ${pack_gid} -s /bin/bash -m

LABEL io.buildpacks.stack.id="heroku-20"
USER heroku
ENV HOME /app
