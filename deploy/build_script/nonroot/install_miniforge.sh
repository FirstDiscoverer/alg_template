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

MINIFORGE_DIR=${HOME}/Software/miniforge

# MiniForge安装
MINIFORGE_URL='https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh'
MINIFORGE_SAVE_PATH="/tmp/miniforge.sh"

wget ${MINIFORGE_URL} -O ${MINIFORGE_SAVE_PATH}
bash ${MINIFORGE_SAVE_PATH} -b -p "${MINIFORGE_DIR}"
rm -rf ${MINIFORGE_SAVE_PATH}

PATH="${MINIFORGE_DIR}/bin:$PATH"
conda init bash
conda clean --all --yes

# Conda配置
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

conda clean --all --yes --verbose
conda config --show-sources
conda config --validate
conda info

# pip配置
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
pip config set global.extra-index-url "https://mirrors.aliyun.com/pypi/simple https://mirrors.cloud.tencent.com/pypi/simple https://pypi.tuna.tsinghua.edu.cn/simple https://mirrors.bfsu.edu.cn/pypi/web/simple"
# ewell网络环境使用腾讯源最快
# pip config set global.index-url https://mirrors.cloud.tencent.com/pypi/simple
# pip config set global.extra-index-url https://mirrors.cloud.tencent.com/pypi/simple

# pip config set global.no-cache-dir true

pip config list