#!/bin/bash

variables=("HOME")
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

echo "使用国内源: ${ENABLE_CHINA_MIRROR}"
# MiniForge安装
MINIFORGE_DIR="${HOME}/Software/miniforge"
MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
if [ "${ENABLE_CHINA_MIRROR}" != "false" ]; then
    MINIFORGE_URL='https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh'
fi
MINIFORGE_SAVE_PATH="/tmp/miniforge.sh"

wget ${MINIFORGE_URL} -O ${MINIFORGE_SAVE_PATH}
bash ${MINIFORGE_SAVE_PATH} -b -p "${MINIFORGE_DIR}"
rm -rf ${MINIFORGE_SAVE_PATH}

PATH="${MINIFORGE_DIR}/bin:$PATH"
conda init bash
mamba clean --all --yes --verbose

# Conda配置
if [ "${ENABLE_CHINA_MIRROR}" != "false" ]; then
  echo "conda 切换到国内源..."
  conda config --set show_channel_urls yes
  conda config --append channels conda-forge
  conda config --set custom_channels.conda-forge https://mirrors.bfsu.edu.cn/anaconda/cloud
  conda config --set custom_channels.msys2 https://mirrors.bfsu.edu.cn/anaconda/cloud
  conda config --set custom_channels.bioconda https://mirrors.bfsu.edu.cn/anaconda/cloud
  conda config --set custom_channels.menpo https://mirrors.bfsu.edu.cn/anaconda/cloud
  conda config --set custom_channels.pytorch https://mirrors.bfsu.edu.cn/anaconda/cloud
  conda config --set custom_channels.simpleitk https://mirrors.bfsu.edu.cn/anaconda/cloud
  # [Anaconda Extra 软件仓库镜像使用帮助](https://help.mirrors.cernet.edu.cn/anaconda-extra/)
  conda config --set custom_channels.nvidia https://mirrors.cernet.edu.cn/anaconda-extra/cloud
fi

conda config --show-sources
conda config --validate
conda info

mamba update -n base -c conda-forge conda --yes --verbose
conda info

mamba clean --all --yes --verbose

# pip配置
if [ "${ENABLE_CHINA_MIRROR}" != "false" ]; then
  echo "pip 切换到国内源..."
  pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
  pip config set global.extra-index-url "https://mirrors.aliyun.com/pypi/simple https://mirrors.cloud.tencent.com/pypi/simple https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple https://mirrors.bfsu.edu.cn/pypi/web/simple"
fi

# pip config set global.no-cache-dir true

pip config list
pip cache purge

# UV配置
if [ "${ENABLE_CHINA_MIRROR}" != "false" ]; then
  echo "UV 切换到国内源..."
mkdir -p "${HOME}/.config/uv"
cat << 'EOF' > "${HOME}/.config/uv/uv.toml"
[[index]]
name = "bfsu"
url = "https://mirrors.bfsu.edu.cn/pypi/web/simple"
default = true

[[index]]
name = "tsinghua"
url = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"

[[index]]
name = "aliyun"
url = "https://mirrors.aliyun.com/pypi/simple"
EOF
fi
