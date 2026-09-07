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
conda create -n tool python=$(conda search python -c conda-forge | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1 | cut -d '.' -f 1,2) -y
conda activate tool
which pip pip3 python python3

pip_install() {
  pip3 install --retries=3 --timeout=30 --no-cache-dir "$@"
}
pip_install uv

uv_install() {
  uv pip install --no-cache "$@"
}
uv_install nvitop glances gpustat

# 2. shell工具
# 2.1 ZSH
OH_MY_ZSH_STR_DIR="\${HOME}/Software/oh-my-zsh"
OH_MY_ZSH_DIR="$(eval echo ${OH_MY_ZSH_STR_DIR})"
ZSHRC_PATH=${HOME}/.zshrc
ZSH_CUSTOM_DIR=${OH_MY_ZSH_DIR}/custom
ZSH_CUSTOM_PLUGIN_DIR=${ZSH_CUSTOM_DIR}/plugins

ZSH_PLUGIN_AUTOSUGGESTIONS="${ZSH_CUSTOM_PLUGIN_DIR}/zsh-autosuggestions"
ZSH_PLUGIN_SYNTAX_HIGHLIGHTING="${ZSH_CUSTOM_PLUGIN_DIR}/zsh-syntax-highlighting"
ZSH_THEME_POWERLEVEL10K="${ZSH_CUSTOM_DIR}/themes/powerlevel10k"

git clone --depth 1 ${GITHUB_MIRROR}/ohmyzsh/ohmyzsh.git ${OH_MY_ZSH_DIR} || { echo "git clone ohmyzsh 失败"; exit 1; }
# git clone --depth 1 https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git "${OH_MY_ZSH_DIR}" || { echo "git clone失败"; exit 1; }
git clone --depth 1 ${GITHUB_MIRROR}/zsh-users/zsh-autosuggestions.git "${ZSH_PLUGIN_AUTOSUGGESTIONS}" || { echo "git clone zsh-autosuggestions失败"; exit 1; }
git clone --depth 1 ${GITHUB_MIRROR}/zsh-users/zsh-syntax-highlighting.git "${ZSH_PLUGIN_SYNTAX_HIGHLIGHTING}" || { echo "git clone zsh-syntax-highlighting失败"; exit 1; }
git clone --depth 1 ${GITHUB_MIRROR}/romkatv/powerlevel10k.git "${ZSH_THEME_POWERLEVEL10K}" || { echo "git clone powerlevel10k失败"; exit 1; }

chmod +x "${ZSH_THEME_POWERLEVEL10K}/gitstatus/install"
zsh "${ZSH_THEME_POWERLEVEL10K}/gitstatus/install"
ls -al ${HOME}/.cache/gitstatus/

# Waring：所有配置必须写在source $ZSH/oh-my-zsh.sh之前，否则不生效
read -r -d '' INSTANT_PROMPT_CONTENT << 'EOF'
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

EOF
echo "${INSTANT_PROMPT_CONTENT}" | cat - "${OH_MY_ZSH_DIR}/templates/zshrc.zsh-template" > "${ZSHRC_PATH}"
sed -i "/^# zstyle ':omz:update' mode reminder/a zstyle ':omz:update' mode disabled" "${ZSHRC_PATH}"
sed -i '/^export ZSH=/ s/^/# /' "${ZSHRC_PATH}"
sed -i "/^# export ZSH=/a export ZSH=${OH_MY_ZSH_STR_DIR}" "${ZSHRC_PATH}"
sed -i '/^plugins=/ s/^/# /' "${ZSHRC_PATH}"
sed -i '/^# plugins=/a plugins=(z git zsh-autosuggestions zsh-syntax-highlighting)' "${ZSHRC_PATH}"
sed -i '/^ZSH_THEME=/ s/^/# /' "${ZSHRC_PATH}"
sed -i '/^# ZSH_THEME=/a ZSH_THEME="powerlevel10k\/powerlevel10k"' "${ZSHRC_PATH}"
# 这个主题配置不能写到.zshrc的最后，否则会导致连接SSH的时候一些符号不显示，必须source .zshrc之后才显示
read -r -d '' OMZ_THEME_CONTENT << 'EOF'
POWERLEVEL9K_MODE="nerdfont-v3"
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time root_indicator background_jobs history anaconda time)
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
EOF
sed -i "/^ZSH_THEME=/r "<(echo "${OMZ_THEME_CONTENT}") "${ZSHRC_PATH}"

echo >> "${ZSHRC_PATH}"
conda init zsh
echo >> "${ZSHRC_PATH}"

export MY_ZSH_CONFIG=/config_my/zsh_config
cat ${MY_ZSH_CONFIG}/profile.sh >> "${ZSHRC_PATH}"


# Final：
echo "【工具检查】"
declare -A cmds=(
  ["fastfetch"]="fastfetch --version || { echo '检查失败'; exit 1; }"
  ["screen"]="screen --version || { echo '检查失败'; exit 1; }"
  ["conda"]="conda --version || { echo '检查失败'; exit 1; }"
  ["uv"]="uv --version || { echo '检查失败'; exit 1; }"
  ["nvitop"]="nvitop --version || { echo '检查失败'; exit 1; }"
  ["glances"]="glances --version || { echo '检查失败'; exit 1; }"
  ["gpustat"]="gpustat --version || { echo '检查失败'; exit 1; }"
  ["zsh"]="zsh --version || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh"]="git -C ${OH_MY_ZSH_DIR} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-plug-autosuggestions"]="git -C ${ZSH_PLUGIN_AUTOSUGGESTIONS} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-plug-syntax-highlighting"]="git -C ${ZSH_PLUGIN_SYNTAX_HIGHLIGHTING} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-theme-powerlevel10k"]="git -C ${ZSH_THEME_POWERLEVEL10K} log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' || { echo '检查失败'; exit 1; }"
  ["oh-my-zsh-theme-powerlevel10k-gitstatusd"]="${HOME}/.cache/gitstatus/gitstatusd-linux-x86_64 -V || { echo '检查失败'; exit 1; }"
)
ordered_keys=("fastfetch" "screen" "conda" "uv" "nvitop" "glances" "gpustat" "zsh" "oh-my-zsh" "oh-my-zsh-plug-autosuggestions" "oh-my-zsh-plug-syntax-highlighting" "oh-my-zsh-theme-powerlevel10k" "oh-my-zsh-theme-powerlevel10k-gitstatusd")
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

conda clean --all --yes --verbose
pip cache purge
uv cache clean