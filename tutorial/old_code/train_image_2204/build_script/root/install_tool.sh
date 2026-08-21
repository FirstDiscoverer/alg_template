#!/bin/bash

variables=("USER_NAME")
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
echo "================所需变量 end  ================"

apt-get clean && apt-get update -y -qq && apt-get upgrade -y -qq

apt_get_install() {
  apt-get install -y --no-install-recommends -qq "$@"
}
# 0. sudo
apt_get_install sudo

# 1. ssh
apt_get_install openssh-server
mkdir -p /var/run/sshd
SSH_CONFIG_PATH=/etc/ssh/sshd_config
cp ${SSH_CONFIG_PATH} /etc/ssh/sshd_config.backup
sed -i '/^#ClientAliveInterval.*/a ClientAliveInterval 60' ${SSH_CONFIG_PATH}
sed -i '/^#ClientAliveCountMax.*/a ClientAliveCountMax 3' ${SSH_CONFIG_PATH}
sed -i '/^#PermitRootLogin.*/a PermitRootLogin no' ${SSH_CONFIG_PATH}
sed -i '/^UsePAM yes/ s/^/# /' ${SSH_CONFIG_PATH}

# 2. supervisor
# sshd必须root启动，所以supervisor也是root启动
apt_get_install supervisor
find /etc/supervisor -type f -name "*.sh" -exec chmod +x {} \;
mkdir -p /var/log/supervisor

# 3. zsh
apt_get_install zsh
chsh -s /bin/zsh "${USER_NAME}"
# ################################ ZSH的问题 start ################################
#【Python3.6 open中文文件错误 or logging中文错误】
# [解决UnicodeEncodeError。python的docker镜像增加locale 中文支持](https://www.cnblogs.com/xuanmanstein/p/9100507.html)
# [docker 中 UnicodeEncodeError: ‘ascii‘ codec can‘t encode characters in position 30-37](https://blog.csdn.net/liuskyter/article/details/114589442)
# ENV LC_ALL=zh_CN.UTF-8
# 已在上个依赖的dockerfile设置

## 【Pycharm使用ssh调试代码缺失环境变量LC_ALL】
# [ssh 连接到docker内，环境变量发生变化的解决方法](https://blog.csdn.net/m0_59029800/article/details/125479518)
# [Linux Shell 初始化文件 —— 环境变量写在哪里？](https://www.rectcircle.cn/posts/linux-shell-initialization-files/)
# [bash zsh differences](https://neovide.dev/faq.html#bash-differences)
# tr '\0' '\n' < /proc/1/environ | grep -Ev '^(NV_|NVIDIA_|CUDA_|HOSTNAME)'  >> /etc/zsh/zshenv
# 改为构建镜像的最后一步执行
# ################################ ZSH的问题 end ################################

# 4. 工具
# 4.1 直接安装
# psmisc: killall
apt_get_install htop psmisc lsof rsync

# 4.2 fastfetch
apt_get_install gnupg2 ca-certificates apt-transport-https software-properties-common
add-apt-repository -y ppa:zhangsongcui3371/fastfetch
apt_get_install fastfetch

# 4.3 screen安装与配置
apt_get_install screen
export SCREEN_LOG=/var/log/screen
mkdir -p ${SCREEN_LOG}
chmod 777 ${SCREEN_LOG}
echo "logfile ${SCREEN_LOG}/%t.log" >> /etc/screenrc
cat /etc/screenrc

# Final: 清理垃圾
apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
