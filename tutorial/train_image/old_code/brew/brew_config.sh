#!/bin/bash

cd ${HOME}

for file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
  # 如果文件不存在，则跳过
  if [ ! -f "${file}" ]; then
    echo "【Brew】${file}不存在，跳过"
    continue
  fi

  # 如果文件中已包含指定的命令，则跳过
  if grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ${file}; then
    echo "【Brew】${file}已存在配置，跳过"
    continue
  fi

  # 如果文件中不包含该命令，则追加到文件末尾
  echo >> ${file}
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${file}
  echo >> ${file}
  cat << 'EOF' >> ${file}
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
EOF
  echo "【Brew】初始化${file}成功"
done