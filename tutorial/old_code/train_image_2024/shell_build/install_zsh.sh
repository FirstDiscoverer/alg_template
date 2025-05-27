#!/bin/bash

variables=("HOME_DIR" "GITHUB_MIRROR")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} 不存在，请确保所有变量都已设置"
        exit 1
    else
        echo "${var}: ${!var}"
    fi
done


apt-get clean && apt-get update -y -q


export OH_MY_ZSH_DIR=${HOME_DIR}/.oh-my-zsh
export ZSH_CUSTOM_DIR=${OH_MY_ZSH_DIR}/custom
export ZSH_CUSTOM_PLUGIN_DIR=${ZSH_CUSTOM_DIR}/plugins
export ZSH_CUSTOM_THEME_DIR=${ZSH_CUSTOM_DIR}/themes
export ZSHRC_PATH=${HOME_DIR}/.zshrc

# ZSH美化
apt-get install -y -q git
git config --global http.sslVerify false
apt-get install -y -q zsh
chsh -s /bin/zsh
git clone ${GITHUB_MIRROR}/ohmyzsh/ohmyzsh.git ${OH_MY_ZSH_DIR} || { echo "git clone失败"; exit 1; }
cp ${OH_MY_ZSH_DIR}/templates/zshrc.zsh-template ${ZSHRC_PATH}
git clone ${GITHUB_MIRROR}/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM_PLUGIN_DIR}/zsh-autosuggestions || { echo "git clone失败"; exit 1; }
git clone ${GITHUB_MIRROR}/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM_PLUGIN_DIR}/zsh-syntax-highlighting || { echo "git clone失败"; exit 1; }
git clone ${GITHUB_MIRROR}/Powerlevel9k/powerlevel9k.git ${ZSH_CUSTOM_THEME_DIR}/powerlevel9k || { echo "git clone失败"; exit 1; }

sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ${ZSHRC_PATH}
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel9k\/powerlevel9k"/g' ${ZSHRC_PATH}
# 这个主题配置不能写到.zshrc的最后，否则会导致连接SSH的时候一些符号不显示，必须source .zshrc之后才显示
sed -i "/ZSH_THEME=\"powerlevel9k\/powerlevel9k\"/r ${HOME_DIR}/zsh_theme" ${ZSHRC_PATH} && rm -rf ${HOME_DIR}/zsh_theme
cat ${HOME_DIR}/zsh_profile >> ${ZSHRC_PATH} && rm -rf ${HOME_DIR}/zsh_profile

conda init zsh

# fastfetch
apt-get install -y -q software-properties-common
add-apt-repository -y ppa:zhangsongcui3371/fastfetch
apt-get install -y -q fastfetch

apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log