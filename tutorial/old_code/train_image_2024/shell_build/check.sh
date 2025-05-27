#!/usr/bin/env zsh

conda --version || { echo "检查失败"; exit 1; }
supervisord --version || { echo "检查失败"; exit 1; }

# zsh
zsh --version || { echo "检查失败"; exit 1; }
source ${HOME_DIR}/.oh-my-zsh/oh-my-zsh.sh
omz version || { echo "检查失败"; exit 1; }
fastfetch --version || { echo "检查失败"; exit 1; }

# tool
nvitop --version || { echo "检查失败"; exit 1; }
gpustat --version || { echo "检查失败"; exit 1; }
screen --version || { echo "检查失败"; exit 1; }
cheat --version || { echo "检查失败"; exit 1; }
cheat -l 2>/dev/null | head -n 5 || { echo "检查失败"; exit 1; }

