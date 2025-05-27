#!/bin/bash

# 镜像源
cp /etc/apt/sources.list /etc/apt/sources.list.bak
sed -i 's/archive.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list

cd /etc/apt/sources.list.d
# 去除CUDA镜像源避免后续apt更新
ls | grep -v '.bak' | grep 'cuda' | xargs -t -i sh -c "mv {} {}.bak"

# 基础工具
apt-get clean && apt-get update -y -q
# 静默升级，防止打断。--force-confdef：让 dpkg 自动使用默认处理方式，而不再反复询问。--force-confold：在发现当前系统的配置文件与新版本冲突时，自动保留你当前的“旧”配置文件。
DEBIAN_FRONTEND=noninteractive \
     apt-get dist-upgrade -y -q \
     -o Dpkg::Options::="--force-confdef" \
     -o Dpkg::Options::="--force-confold"
apt-get clean && apt-get update -y -q && apt-get upgrade -y -q
apt-get install -y -q language-pack-zh-hans
apt-get install -y -q locales && locale-gen zh_CN.UTF-8 && update-locale LANG=zh_CN.UTF-8 && locale
apt-get install -y -q coreutils vim unzip wget curl telnet iputils-ping net-tools

export TZ=Asia/Shanghai
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
apt-get install -y -q tzdata && dpkg-reconfigure --frontend noninteractive tzdata
apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log