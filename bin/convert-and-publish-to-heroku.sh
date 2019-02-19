#!/bin/sh

sudo cp tools/bin/* /usr/local/bin
sudo convert-to-heroku-stack-image $STACK
