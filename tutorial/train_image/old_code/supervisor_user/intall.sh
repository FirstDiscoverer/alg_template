#!/bin/bash

# sshd必须docker启动，所以supervisor改为root安装启动，而不是用户

variables=("MINIFORGE_DIR")
echo "================所需变量 start================"
echo "user=$(whoami), pwd=$(pwd)"
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} 不存在，请确保所有变量都已设置"
        exit 1
    else
        echo "${var}: ${!var}"
    fi
done
echo "================所需变量 end================"

which pip3

pip_install() {
  pip3 install --retries=3 --timeout=30 --no-cache-dir "$@"
}

# 1 Python工具
# 1.1 supervisor
pip_install supervisor

export SUPERVISORD_CONF_DIR=${HOME}/.config/supervisor
find ${SUPERVISORD_CONF_DIR} -type f -name "*.sh" -exec chmod +x {} \;
export SUPERVISORD_CONF_PATH=${SUPERVISORD_CONF_DIR}/supervisord.conf
# [echo_supervisord_conf](https://supervisord.org/installing.html?highlight=echo_supervisord_conf)
echo_supervisord_conf > ${SUPERVISORD_CONF_PATH}
echo >> ${SUPERVISORD_CONF_PATH}
cat << 'EOF' >> ${SUPERVISORD_CONF_PATH}
[include]
files = %(ENV_HOME)s/.config/supervisor/conf.d/*.ini
# user=root
EOF
ln -s ${SUPERVISORD_CONF_PATH} ${MINIFORGE_DIR}/etc/supervisord.conf