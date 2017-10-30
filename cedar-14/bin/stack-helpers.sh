# Whilst this file really belongs in the `bin/` directory in the repo root, it has
# to be within the `cedar-14/` hierarchy so that it's accessible via `/vagrant/`
# when using the the legacy Vagrant environment.

set -o pipefail

function display() {
  echo -e "\n----->" $*
}

function abort() {
  echo $* ; exit 1
}

function indent() {
  sed "s/^/       /"
}
