# 1 基础GPU环境

==**不推荐使用此环境，建议使用`3 训练环境-zsh`**==

## 1.1 介绍

包含以下内容：

- 最高版本的CUDA

- Mini Conda环境

## 1.2 镜像构建

`CUDA_VERSION` 参考 [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda/tags)(CUDA 11及其以上)

```shell

# ① 选择CUDA版本
# a. CUDA 11 以上  start
export CUDA_VERSION="11.8.0-cudnn8-devel-ubuntu22.04"
# export CUDA_VERSION="11.3.1-cudnn8-devel-ubuntu20.04"
# export CUDA_VERSION="11.6.2-cudnn8-devel-ubuntu20.04"
# export CUDA_VERSION="11.2.2-cudnn8-devel-ubuntu20.04"
export PULL_CUDA_VERSION="nvidia/cuda:${CUDA_VERSION}"
# CUDA 11 以上  end

# b. CUDA 10 start
export CUDA_VERSION="10.0-cudnn7-devel-ubuntu18.04"
export PULL_CUDA_VERSION="sitonholy/cuda${CUDA_VERSION}:v1.0"

# export CUDA_VERSION="10.0-cudnn7.4-ubuntu18.04"
# export PULL_CUDA_VERSION="mohammadsh/cuda${CUDA_VERSION}:latest"
# CUDA 10 end

# ② 拉取镜像
docker pull ${PULL_CUDA_VERSION}

# ③ 构建镜像
export GPU_IMAGE_VERSION="cuda${CUDA_VERSION}-miniconda"

docker build \
-f "cuda-miniconda.Dockerfile" \
-t "alg:${GPU_IMAGE_VERSION}" \
--build-arg PULL_CUDA_VERSION=${PULL_CUDA_VERSION} \
--network=host \
--progress=plain \
.
```

## 1.3 容器运行

```bash
docker run -d \
--name lx_train \
--restart unless-stopped \
--gpus all \
-v /home/lx/workspace:/workspace \
alg:${GPU_IMAGE_VERSION} \ # 自定义镜像版本
/bin/sh -c "while true; do date; sleep 10; done"
```

# 2 训练环境-ssh

==**已废弃，直接使用`3 训练环境-zsh`**==

## 2.1 介绍

包含以下内容：

- 最高版本的CUDA
- Mini Conda环境
- SSH服务

## 2.2 镜像构建

```bash
export GPU_SSH_IMAGE_VERSION="${GPU_IMAGE_VERSION}-ssh"

docker build \
-f "cuda-miniconda-ssh.Dockerfile" \
-t alg:${GPU_SSH_IMAGE_VERSION} \
--build-arg FROM_VERSION=${GPU_IMAGE_VERSION} \
--network=host \
--progress=plain \
.
```

## 2.3 容器运行

```bash
# 注意修改 容器name、ssh端口映射、volume映射

# 有ssh镜像
docker run -d \
--name lx_train \
--restart unless-stopped \
--gpus all \
--env SSH_PASSWORD=ewell123 \
-p 10022:22 \
-v /home/lx/workspace:/workspace \
alg:${GPU_SSH_IMAGE_VERSION}   # 【自定义镜像版本】

ssh root@127.0.0.1 -p 10022
```

# 3 训练环境-zsh

## 3.1 介绍

包含以下内容：

- 最高版本的CUDA
- Mini Conda环境
- SSH服务
- ZSH终端美化
- 系统监控工具

## 3.2 镜像构建

```bash
export GPU_SSH_ZSH_IMAGE_VERSION="${GPU_IMAGE_VERSION}-ssh-zsh"

docker build \
-f "cuda-miniconda-ssh-zsh.Dockerfile" \
-t alg:${GPU_SSH_ZSH_IMAGE_VERSION} \
--build-arg FROM_VERSION=${GPU_IMAGE_VERSION} \
--network=host \
--progress=plain \
.
```

## 3.3 容器运行

**==推荐方式==**

docker-compose.yml

```yaml
version: "3.8"

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "10"

services:
  【名字拼音缩写，如lx】_train:
    container_name: "【名字拼音缩写，如lx】_train"
    # hostname: "container-xxx"
    image: alg:cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh   # 【自定义镜像版本】
    restart: unless-stopped
    environment:
      SSH_PASSWORD: ewell123        #【自定义SSH密码】
    ports:
      - "1022:22"    # 【自定义SSH端口映射】
      - "18080:8080" # 【自定义WEB端口映射，方便容器中WEB服务的调试】
    volumes:
      - /workspace/user/【用户名】/code:/workspace
      - /workspace/user/【用户名】/Docker/cache:/root/.cache
      - /workspace/data_share:/data_share:ro   # 共享目录映射
    healthcheck:
      test: [ "CMD", "supervisorctl", "status" ]
      interval: 5s
      timeout: 2s
      retries: 3
    extra_hosts:
      - "gpu_train.ewell.server:192.168.120.149"
      - "gpu_deploy.ewell.server:192.168.120.148"
    sysctls:
      net.ipv4.tcp_keepalive_time: 864000
    deploy:
      resources:
        reservations:
          devices:
            - driver: "nvidia"
              count: "all"
              capabilities: [ "gpu" ]
    shm_size: '2gb'
    logging: *default-logging
```

```bash
# 部署容器
docker-compose up -d

# 两种进入容器方式：
# ① ssh
ssh root@127.0.0.1 -p 1022
ssh root@主机IP -p 1022
# 密码：ewell123

# ② Docker
docker exec -it lx_train zsh
```

**注意**：

- 为什么设置shm内存大小？
    - [更改Docker的shm（共享内存）大小](https://blog.csdn.net/qq_33420835/article/details/109013202)
- 为什么设置net.ipv4.tcp_keepalive_time？
    - 避免容器与其他主机连接时(如长时间SQL操作，未返回数据)，出现程序TCP断开问题，默认是两个小时
    - 参考资料
        - [Re: Application outage with XX000: could not receive data from client: Connection timed out](https://www.postgresql.org/message-id/87tv1cqnq6.fsf%40jsievers.enova.com)
        - [15 容器网络：我修改了_proc_sys_net下的参数，为什么在容器中不起效？](https://learn.lianglianglee.com/%E4%B8%93%E6%A0%8F/%E5%AE%B9%E5%99%A8%E5%AE%9E%E6%88%98%E9%AB%98%E6%89%8B%E8%AF%BE/15%20%E5%AE%B9%E5%99%A8%E7%BD%91%E7%BB%9C%EF%BC%9A%E6%88%91%E4%BF%AE%E6%94%B9%E4%BA%86_proc_sys_net%E4%B8%8B%E7%9A%84%E5%8F%82%E6%95%B0%EF%BC%8C%E4%B8%BA%E4%BB%80%E4%B9%88%E5%9C%A8%E5%AE%B9%E5%99%A8%E4%B8%AD%E4%B8%8D%E8%B5%B7%E6%95%88%EF%BC%9F.md)
        - [TCP KeepAlive机制理解与实践小结 - 博客园](https://www.cnblogs.com/hueyxu/p/15759819.html)
            - 被容器连接的主机也需要设置，通过`sysctl net.ipv4.tcp_keepalive_time`
              查看，通过`sysctl net.ipv4.tcp_keepalive_time=864000`设置超时时间为10天

## 3.4 注意事项

### 3.4.1 终端字体显示不全

推荐终端使用[Hack Nerd Font](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-installation)字体

### 3.4.2 TensorFlow注意事项

① 低版本Tensorflow(1.xx版本)，如果使用runtime镜像，必须使用Conda安装TensorFlow，会自动安装Tensorflow对应版本的cudatoolkit与cudnn

[完美解决TensorFlow-gpu报错问题Could not load dynamic library ‘libnvinfer.so.6’ and ‘libcudart.so.11.0’_](http://www.4k8k.xyz/article/weixin_41194129/120215865)

```bash
conda search tensorflow-gpu 
conda search tensorflow-gpu --channel conda-forge
# 可尝试是否指定channel为conda-forge，否则可能会找不到gpu的包
conda install -n [your_env_name] -y tensorflow-gpu==1.xxx -c conda-forge
# 清除下载包，占用空间较大
conda clean --all -y --verbose
```

② 高版本Tensorflow(2.xx版本) ，使用GPU异常，直接使用devel镜像，而不是runtime

[FIx for "Couldn't invoke ptxas --version" with cuda-11.3 and jaxlib 0.1.66+cuda111](https://github.com/google/jax/discussions/6843)

**==注意==**：建议根据[TensorFlow与Cuda的版本对应关系](https://www.tensorflow.org/install/source#gpu)，选择相应版本的*
*devel**镜像

### 3.4.3 command not found: print_icon问题

问题：Windows使用XShell连接提示该问题

分析：

```shell
# Windows使用SSH连接容器
root@733dc3f23f5f  ~ locale                                                                                 
LANG=
LANGUAGE=
LC_CTYPE="POSIX"
LC_NUMERIC="POSIX"
LC_TIME="POSIX"
LC_COLLATE="POSIX"
LC_MONETARY="POSIX"
LC_MESSAGES="POSIX"
LC_PAPER="POSIX"
LC_NAME="POSIX"
LC_ADDRESS="POSIX"
LC_TELEPHONE="POSIX"
LC_MEASUREMENT="POSIX"
LC_IDENTIFICATION="POSIX"
LC_ALL=

# Mac使用SSH连接容器
 root@733dc3f23f5f  ~  locale  
LANG=zh_CN.UTF-8
LANGUAGE=
LC_CTYPE="zh_CN.UTF-8"
LC_NUMERIC="zh_CN.UTF-8"
LC_TIME="zh_CN.UTF-8"
LC_COLLATE="zh_CN.UTF-8"
LC_MONETARY="zh_CN.UTF-8"
LC_MESSAGES="zh_CN.UTF-8"
LC_PAPER="zh_CN.UTF-8"
LC_NAME="zh_CN.UTF-8"
LC_ADDRESS="zh_CN.UTF-8"
LC_TELEPHONE="zh_CN.UTF-8"
LC_MEASUREMENT="zh_CN.UTF-8"
LC_IDENTIFICATION="zh_CN.UTF-8"
LC_ALL=
```

~~原因在于Windows的工具改了默认的locale~~

~~解决：在镜像构建中中`apt install language-pack-en`~~

~~[icons.zsh:168: character not in range](https://github.com/Powerlevel9k/powerlevel9k/issues/639)~~

已通过设置`LC_ALL`解决

# 4 Python

已删除，直接使用`3 训练环境-zsh`

# 5 C++

**==废弃==**

## 5.1 介绍

包含以下内容：

- Ubuntu LST版本 20.04
- C++环境：CMake
- SSH服务
- ZSH终端美化

## 5.2 镜像构建

```bash
docker build -f "dev_cpp.Dockerfile" -t dev_cpp:1.0 --network=host .
```

## 5.3 容器运行

```bash
docker run -d \
--name lx_dev_cpp \
--restart unless-stopped \
--security-opt seccomp=unconfined \
-p 10022:22 \
dev_cpp:1.0

```

## 5.4 调试容器

```bash
docker run -d \
--name test_ubuntu \
ubuntu:20.04 \
/bin/sh -c "while true; do date; sleep 10; done"

docker exec -it test_ubuntu bash
```

# 6 其他

## 6.1 训练环境升级镜像，不删除已存在的conda环境

```shell
# 1. 将容器中的conda环境复制到宿主机
docker cp 【容器名】:/opt/app/miniconda /workspace/user/【用户名】/Docker/miniconda

# 2. 创建容器时添加目录映射
-v /workspace/user/【用户名】/Docker/miniconda:/opt/app/miniconda
```

## 6.2 容器中安装Oracle

```bash
mkdir -p /opt/oracle
cd /opt/oracle
wget https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip
unzip instantclient-basic-linux.x64-21.6.0.0.0dbru.zip
apt-get install libaio-dev -y
sh -c "echo /opt/oracle/instantclient_21_6 > /etc/ld.so.conf.d/oracle-instantclient.conf"
ldconfig
```

## 6.3 Docker端口映射测试

目的：测试部分机器Docker的bridge网络模式下端口是否成功映射

注意：228服务器中Docker网络有问题

```bash
docker stop test_net && docker rm test_net

docker run -d \
	--name test_net \
	--net host \
	nginx

# 230、221机器下两种方式都可以

docker run -d \
	--name test_net \
	-p 10080:80 \
	nginx

docker run -d \
	--name test_net2 \
	--net default \
	-p 20080:80 \
	nginx

curl http://127.0.0.1:10080
curl http://127.0.0.1:20080
```

## 6.4 清理中间构建镜像

清理 原始CUDA、基于CUDA的bash镜像

```bash
docker images | grep -E 'nvidia/cuda|ew-alg' | grep -v 'zsh' | grep -E 'nvidia/cuda|ssh' | awk -v OFS=":" '{print $1,$2}' | xargs docker rmi
```

# 7 常见问题

## 7.1 docker-compose构建镜像时出现 failed to solve with frontend dockerfile.v0

[failed to solve with frontend dockerfile.v0: failed to build LLB: executor failed running - runc did not terminate sucessfully ](https://github.com/docker/buildx/issues/426)

此问题在231机器上出现

解决：在构建前添加

```shell
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
```

231已经全局(`/etc/profile`)添加

推测原因

```shell
# 有可能能是因为docker网络在不同的zones造成
# 有可能完全卸载Docker & 删除所有的docker网桥 & 再次安装Docker可以解决
firewall-cmd --get-active-zones
```

## 7.2 Why can't I run command “nvcc --version" in docker-CUDA Container?

使用devel替代runtime

[Why can't I run command “nvcc --version" in docker-CUDA Container?](https://github.com/NVIDIA/nvidia-docker/issues/1160)

[Why can't I run command “nvcc --version" in docker-CUDA Container?](https://askubuntu.com/questions/1197191/why-cant-i-run-command-nvcc-version-in-docker-cuda-container)
