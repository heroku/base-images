#!/bin/bash

function append_once() {
  while read data; do
    grep -q "$data" $1 || echo "$data" >> $1
  done
}

apt-get update
apt-get -y --force-yes install curl git-core lxc

# mount cgroup for LXC
mkdir -p /cgroup
mount none -t cgroup /cgroup
append_once /etc/fstab <<EOF
  none /cgroup cgroup defaults 0 0
EOF

# download or build a cedar image