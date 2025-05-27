#!/bin/bash

# 1. 项目环境构建
apt-get update
# apt-get install -y xxx


# 2. GPU环境构建
# ① Tensorflow使用GPU
# conda search tensorflow-gpu --channel conda-forge
# conda install -n ${DEPLOY_ENV} -y tensorflow-gpu==1.xxx -c conda-forge # 若Tensorflow安装找不到，确认该版本的Tensorflow是否支持当前conda环境的Python版本

# ② Pytorch使用GPU
# 参照Pytorch官网来安装GPU版本的Pytorch，会自动装好依赖的CUDA https://pytorch.org/get-started/previous-versions/
# 例如：pip install torch==2.1.2 --index-url https://download.pytorch.org/whl/cu118 --retries=3 --timeout=30 --no-cache-dir

# ③ 百度的PaddlePaddle使用GPU
# a. 按照PaddlePaddle需要的CUDA版本修改Dockerfile的FROM的版本，例如：`FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04`
# b. 参照百度官网来安装GPU版本PaddlePaddle


# Final：清理垃圾
apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
conda clean --all --yes --verbose