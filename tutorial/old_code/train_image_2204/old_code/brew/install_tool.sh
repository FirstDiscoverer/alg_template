#!/bin/bash

apt-get clean && apt-get update -y -q && apt-get upgrade -y -q

apt_get_install() {
  apt-get install -y --no-install-recommends -q "$@"
}

# 1. linuxbrew
apt_get_install build-essential