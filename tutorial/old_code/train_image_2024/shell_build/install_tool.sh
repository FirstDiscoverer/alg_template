#!/bin/bash

variables=("HOME_DIR" "CONFIG_DIR" "GITHUB_MIRROR" "GITHUB_DOWN_MIRROR")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} 不存在，请确保所有变量都已设置"
        exit 1
    else
        echo "${var}: ${!var}"
    fi
done

apt-get clean && apt-get update -y -q

# 1. apt工具
apt-get install -y -q glances htop psmisc lsof rsync

# 2. Python工具
which pip3
pip3 install nvitop gpustat --no-cache-dir

# 3. Linux工具
# 3.1 screen
# [Linux Screen技巧：记录屏幕日志](https://blog.csdn.net/lovemysea/article/details/78344114)
apt-get install -y -q screen
export SCREEN_LOG=/var/log/screen
mkdir -p ${SCREEN_LOG}
echo "logfile ${SCREEN_LOG}/%t.log" >> /etc/screenrc
cat /etc/screenrc

# 3.2 cheat
# ① cheat安装
cd /tmp
wget ${GITHUB_DOWN_MIRROR}/cheat/cheat/releases/download/4.4.2/cheat-linux-amd64.gz || { echo "下载失败"; exit 1; }
gunzip cheat-linux-amd64.gz
chmod +x cheat-linux-amd64
mv cheat-linux-amd64 /usr/local/bin/cheat
which cheat
# ② cheat配置
mkdir -p ${HOME_DIR}/.config/cheat
export CHEAT_CONFIG_FILE=${HOME_DIR}/.config/cheat/conf.yml
cheat --init > ${CHEAT_CONFIG_FILE}
# [failed to write to pager: exec: "PAGER_PATH": executable file not found in $PATH](https://github.com/cheat/cheat/issues/721)
sed -i 's/pager: PAGER_PATH/pager: less -FRX/g' ${CHEAT_CONFIG_FILE}
export CHEAT_SHEETS_DIR=${CONFIG_DIR}/cheatsheets
git clone --depth=1 ${GITHUB_MIRROR}/cheat/cheatsheets.git ${CHEAT_SHEETS_DIR} || { echo "git clone失败"; exit 1; }
# 个人配置文件夹必须得存在
mkdir -p ${HOME_DIR}/.config/cheat/cheatsheets/personal
ln -sf ${CHEAT_SHEETS_DIR} ${HOME_DIR}/.config/cheat/cheatsheets/community



apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log