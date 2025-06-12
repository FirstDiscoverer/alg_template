#!/bin/bash

export MINIFORGE_DIR=${HOME}/Software/miniforge
export GITHUB_MIRROR='https://github.com'
#export GITHUB_MIRROR='https://githubfast.com'
# export GITHUB_DOWN_MIRROR='https://www.ghproxy.cc/https://github.com'
variables=("HOME" "MINIFORGE_DIR" "GITHUB_MIRROR")
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

# 1. Python 工具
source "${MINIFORGE_DIR}/etc/profile.d/conda.sh"
which conda
conda activate base
which pip pip3 python python3

pip_install() {
  pip3 install --retries=3 --timeout=30 --no-cache-dir "$@"
}

pip_install nvitop glances gpustat

# 2. shell工具
# 2.1 ZSH
OH_MY_ZSH_STR_DIR="\${HOME}/Software/oh-my-zsh"
OH_MY_ZSH_DIR="$(eval echo ${OH_MY_ZSH_STR_DIR})"
ZSHRC_PATH=${HOME}/.zshrc
ZSH_CUSTOM_DIR=${OH_MY_ZSH_DIR}/custom
ZSH_CUSTOM_PLUGIN_DIR=${ZSH_CUSTOM_DIR}/plugins

ZSH_PLUGIN_AUTOSUGGESTIONS="${ZSH_CUSTOM_PLUGIN_DIR}/zsh-autosuggestions"
ZSH_PLUGIN_SYNTAX_HIGHLIGHTING="${ZSH_CUSTOM_PLUGIN_DIR}/zsh-syntax-highlighting"
ZSH_THEME_POWERLEVEL9K="${ZSH_CUSTOM_DIR}/themes/powerlevel9k"

# git clone ${GITHUB_MIRROR}/ohmyzsh/ohmyzsh.git ${OH_MY_ZSH_DIR} || { echo "git clone失败"; exit 1; }
git clone https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git "${OH_MY_ZSH_DIR}" || { echo "git clone失败"; exit 1; }
git clone ${GITHUB_MIRROR}/zsh-users/zsh-autosuggestions.git "${ZSH_PLUGIN_AUTOSUGGESTIONS}" || { echo "git clone失败"; exit 1; }
git clone ${GITHUB_MIRROR}/zsh-users/zsh-syntax-highlighting.git "${ZSH_PLUGIN_SYNTAX_HIGHLIGHTING}" || { echo "git clone失败"; exit 1; }
git clone ${GITHUB_MIRROR}/Powerlevel9k/powerlevel9k.git "${ZSH_THEME_POWERLEVEL9K}" || { echo "git clone失败"; exit 1; }

cp "${OH_MY_ZSH_DIR}/templates/zshrc.zsh-template" "${ZSHRC_PATH}"
sed -i '/^export ZSH=/ s/^/# /' "${ZSHRC_PATH}"
sed -i "/^# export ZSH=/a export ZSH=${OH_MY_ZSH_STR_DIR}" "${ZSHRC_PATH}"
sed -i '/^plugins=/ s/^/# /' "${ZSHRC_PATH}"
sed -i '/^# plugins=/a plugins=(z git zsh-autosuggestions zsh-syntax-highlighting)' "${ZSHRC_PATH}"
sed -i '/^ZSH_THEME=/ s/^/# /' "${ZSHRC_PATH}"
sed -i '/^# ZSH_THEME=/a ZSH_THEME="powerlevel9k\/powerlevel9k"' "${ZSHRC_PATH}"
# 这个主题配置不能写到.zshrc的最后，否则会导致连接SSH的时候一些符号不显示，必须source .zshrc之后才显示
export MY_ZSH_CONFIG=/config_my/zsh_config
sed -i "/^ZSH_THEME=/r ${MY_ZSH_CONFIG}/omz_theme" "${ZSHRC_PATH}"
echo >> "${ZSHRC_PATH}"
conda init zsh
echo >> "${ZSHRC_PATH}"
cat ${MY_ZSH_CONFIG}/profile.sh >> "${ZSHRC_PATH}"


# Final：
echo "【工具检查】"
declare -A cmds=(
  ["fastfetch"]="fastfetch --version || { echo '检查失败'; exit 1; }"
  ["screen"]="screen --version || { echo '检查失败'; exit 1; }"
  ["conda"]="conda --version || { echo '检查失败'; exit 1; }"
  ["nvitop"]="nvitop --version || { echo '检查失败'; exit 1; }"
  ["glances"]="glances --version || { echo '检查失败'; exit 1; }"
  ["gpustat"]="gpustat --version || { echo '检查失败'; exit 1; }"
  ["zsh"]="zsh --version || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh"]="git -C ${OH_MY_ZSH_DIR} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-plug-autosuggestions"]="git -C ${ZSH_PLUGIN_AUTOSUGGESTIONS} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-plug-syntax-highlighting"]="git -C ${ZSH_PLUGIN_SYNTAX_HIGHLIGHTING} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-theme-powerlevel9k"]="git -C ${ZSH_THEME_POWERLEVEL9K} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
)
ordered_keys=("fastfetch" "screen" "conda" "nvitop" "glances" "gpustat" "zsh" "oh-my-zsh" "oh-my-zsh-plug-autosuggestions" "oh-my-zsh-plug-syntax-highlighting" "oh-my-zsh-theme-powerlevel9k")
sorted_cmds_keys=$(printf "%s\n" "${!cmds[@]}" | sort | tr '\n' ' ')
sorted_ordered_keys=$(printf "%s\n" "${ordered_keys[@]}" | sort | tr '\n' ' ')
if [ "$sorted_cmds_keys" = "$sorted_ordered_keys" ]; then
    echo "校验通过：ordered_keys 和 cmds 的 key 完全一致"
else
    echo "错误：ordered_keys 和 cmds 的 key 不一致！"
    echo "ordered_keys: ${sorted_ordered_keys}"
    echo "   cmds keys: ${sorted_cmds_keys}"
    exit 1
fi
for name in "${ordered_keys[@]}"; do
    version=$(eval "${cmds[$name]}")
    echo -e "【${name}】\n${version}\n"
done
