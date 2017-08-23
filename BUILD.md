Building Stack Images
=====================

Heroku-16
---------

To build the Heroku-16 images locally, run this from the repo root:

    ./docker-build.sh heroku-16

This will generate both the runtime image (`heroku/heroku:16`) and also the larger
build image (`heroku/heroku:16-build`) that includes development headers/compilers.


Cedar-14
--------

Unlike Heroku-16, the Cedar-14 image used on Heroku dynos is built using debootstrap
from within a Vagrant environment rather than via the included Dockerfile. However the
`cedar-14/bin/cedar-14.sh` script is used by both, so the differences are minimal.

To build the `heroku/cedar:14` Docker image locally, run this from the repo root:

    ./docker-build.sh cedar-14

To build the production version of the image, run this from the repo root:

    cd cedar-14
    vagrant up
    vagrant ssh

    sudo /vagrant/bin/build-stack 14.4.0 /vagrant/bin/cedar-14.sh
    -----> Starting build
    -----> Installing build tools
           ...
    -----> Cleaning up. Logs at /tmp/log/build-stack.log

    sudo /vagrant/bin/capture-stack 14.4.0
    -----> Starting capture
    -----> Creating image file /tmp/cedar64-14.4.0.img
           ...
    -----> Cleaning up. Logs at /tmp/log/capture-stack.log

And then upload to S3 using:

    export AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=xxx
    sudo -E /vagrant/bin/push-stack 14.4.0 stacks_bucket
    -----> Starting push
    -----> Uploading files
           ...
    -----> Cleaning up. Logs at /tmp/log/push-stack.log
