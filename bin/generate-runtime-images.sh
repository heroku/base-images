#!/usr/bin/env bash

set -euo pipefail

STACK_VERSION="${1:-"NAN"}"
[[ $STACK_VERSION =~ ^[0-9]+$ ]] || (abort "fatal: invalid STACK_VERSION")

sudo cp tools/bin/* /usr/local/bin
sudo -E convert-to-heroku-stack-image "heroku-${STACK_VERSION}"
