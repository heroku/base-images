# shellcheck shell=bash

function display() {
  echo -e "\n-----> $1"
}

function abort() {
  printf '\e[1;31m%s\n\e[0m' "$1"
  exit 1
}

function indent() {
  sed "s/^/       /"
}
