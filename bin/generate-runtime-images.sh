#!/usr/bin/env bash

set -euo pipefail

STACK_VERSION="${1:-"NAN"}"
[[ $STACK_VERSION =~ ^[0-9]+$ ]] || (abort "fatal: invalid STACK_VERSION")

sudo cp tools/bin/* /usr/local/bin
# On Debian, /etc/sudoers has secure_path set to prevent PATH forwarding
sudo -E env "PATH=$PATH" convert-to-heroku-stack-image "${STACK_VERSION}"
