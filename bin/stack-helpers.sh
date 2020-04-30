# shellcheck shell=bash

function display() {
  echo -e "\n-----> $1"
}

function abort() {
  echo "$1"
  exit 1
}

function indent() {
  sed "s/^/       /"
}
