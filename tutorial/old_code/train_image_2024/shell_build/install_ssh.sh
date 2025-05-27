#!/bin/bash

# SSH [用Dockerfile配置SSH远端登陆ubuntu](https://www.jianshu.com/p/a97faf8b6da1)

variables=("HOME_DIR")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} 不存在，请确保所有变量都已设置"
        exit 1
    else
        echo "${var}: ${!var}"
    fi
done

apt-get clean && apt-get update -y -q

apt-get install -y -q openssh-server
mkdir -p /var/run/sshd
mkdir -p ${HOME_DIR}/.ssh

sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config
sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log