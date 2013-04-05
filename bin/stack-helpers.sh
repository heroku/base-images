set -o pipefail

function display() {
  echo -e "\n----->" $*
}

function abort() {
  echo $* ; exit 1
}

function indent() {
  sed -u "s/^/       /"
}