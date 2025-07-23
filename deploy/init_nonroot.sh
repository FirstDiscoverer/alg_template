#!/bin/bash

variables=("APP_DEPLOY_ENV")
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

which pip pip3 python python3

# GPU环境构建可在这里单独构建一层。避免和后面的requirement.txt放在一起安装，因为GPU相关的耗时久

# ① Tensorflow使用GPU
# conda search tensorflow-gpu --channel conda-forge
# conda install -n ${APP_DEPLOY_ENV} -y tensorflow-gpu==1.xxx -c conda-forge # 若Tensorflow安装找不到，确认该版本的Tensorflow是否支持当前conda环境的Python版本

# ② Pytorch使用GPU
# 参照Pytorch官网来安装GPU版本的Pytorch，会自动装好依赖的CUDA https://pytorch.org/get-started/previous-versions/
# 例如：pip install torch==2.1.2 --index-url https://download.pytorch.org/whl/cu118 --retries=3 --timeout=30 --no-cache-dir

# ③ 百度的PaddlePaddle使用GPU
# a. 按照PaddlePaddle需要的CUDA版本修改Dockerfile的FROM的版本，例如：`FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04`
# b. 参照百度官网来安装GPU版本PaddlePaddle
