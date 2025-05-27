#!/bin/bash

# [Run multiple services in a container](https://docs.docker.com/config/containers/multi-service_container/)
# [UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations](https://stackoverflow.com/questions/63608075/userwarning-supervisord-is-running-as-root-and-it-is-searching-for-its-configur)

variables=("CONFIG_DIR")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} 不存在，请确保所有变量都已设置"
        exit 1
    else
        echo "${var}: ${!var}"
    fi
done

apt-get clean && apt-get update -y -q

apt-get install -y -q supervisor
mkdir -p /var/log/supervisor
echo "user=root" >> /etc/supervisor/supervisord.conf

rm -rf /etc/supervisor/conf.d
ln -s ${CONFIG_DIR}/supervisor /etc/supervisor/conf.d
ls -l /etc/supervisor/conf.d/
chmod 755 ${CONFIG_DIR}/supervisor/*.sh

apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log