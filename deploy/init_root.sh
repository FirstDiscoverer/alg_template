#!/bin/bash

apt-get clean && apt-get update -y -qq && apt-get upgrade -y -qq

apt_get_install() {
  apt-get install -y --no-install-recommends -qq "$@"
}

# 系统命令安装
# apt_get_install xxx

apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log