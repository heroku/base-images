#!/usr/bin/env bash

set -euo pipefail

sudo cp tools/bin/* /usr/local/bin
sudo -E convert-to-heroku-stack-image "${STACK}"
