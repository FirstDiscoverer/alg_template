# 1 基础GPU环境

## 1.1 介绍

包含以下内容：

- [Long Term Support Branch](https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-and-drivers-table) 的Nvidia驱动支持的CUDA
- 非root用户
- MiniForge环境

## 1.2 镜像构建

```shell
cd ./docker-compose/cuda-版本/miniforge

BUILDKIT_PROGRESS=plain docker-compose build --no-cache
```

- 若要修改CUDA版本
    - build.args中的`ORIGINAL_IMAGE`
        - CUDA 11及其以上：查看[nvidia/cuda](https://hub.docker.com/r/nvidia/cuda/tags)，例如：`nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04`
        - CUDA 10：`sitonholy/cuda:10.0-cudnn7-devel-ubuntu18.04`
    - 修改要构建的image名称，与`ORIGINAL_IMAGE`对应

# 2 训练环境-zsh

## 2.1 介绍

包含以下内容：

- 基础GPU环境
- SSH服务
- ZSH终端主题美化、历史命令提示工具
- 监控工具：htop、glances、nvitop等
- 常用工具：lsof、rsync、screen等

## 2.2 镜像构建

```shell
cd ./docker-compose/cuda-版本/miniforge-ssh-zsh

BUILDKIT_PROGRESS=plain docker-compose build --no-cache
```

- 若要修改CUDA版本
    - build.args中的`ORIGINAL_IMAGE`：使用 `1 基础GPU环境` 构建出的镜像名
    - 修改要构建的image名称，与 `ORIGINAL_IMAGE` 对应

## 2.3 容器运行

### 2.3.1 最小docker-compose配置

```yaml
x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "10"

services:
  【名字拼音缩写，如lx】_train:
    container_name: "【名字拼音缩写，如lx】_train"
    # hostname: "container-xxx"
    image: alg:cuda11.8.0-cudnn8-devel-ubuntu22.04-miniforge-ssh-zsh   # 【自定义镜像版本】
    restart: unless-stopped
    ports:
      - "1022:22"    # 【自定义SSH端口映射】
      - "18080:8080" # 【自定义WEB端口映射，方便容器中WEB服务的调试】
    volumes:
      - ${CODE_DIR}:/home/appuser/Workspace  # 代码位置
    healthcheck:
      test: [ "CMD", "supervisorctl", "status" ]
      interval: 5s
      timeout: 2s
      retries: 3
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

```shell
# 部署容器
docker-compose up -d
```

### 2.3.2 进入容器方式

```shell
# 两种进入容器方式：

# ① ssh
ssh appuser@127.0.0.1 -p 1022
ssh appuser@主机IP -p 1022
# appuser用户密码：app@123
# root用户密码root@123。注意：root不可以通过ssh登陆，普通用户appuser具有sudo权限

# ② docker进入
docker exec -it -u appuser 容器名 zsh
```

### 2.3.3 部分配置介绍

- 为什么设置shm内存大小？
    - [更改Docker的shm（共享内存）大小](https://blog.csdn.net/qq_33420835/article/details/109013202)
- 为什么设置net.ipv4.tcp_keepalive_time？
    - 避免容器与其他主机连接时(如长时间SQL操作，未返回数据)，出现程序TCP断开问题，默认是两个小时
    - 参考资料
        - [Re: Application outage with XX000: could not receive data from client: Connection timed out](https://www.postgresql.org/message-id/87tv1cqnq6.fsf%40jsievers.enova.com)
        - [15 容器网络：我修改了_proc_sys_net下的参数，为什么在容器中不起效？](https://learn.lianglianglee.com/%E4%B8%93%E6%A0%8F/%E5%AE%B9%E5%99%A8%E5%AE%9E%E6%88%98%E9%AB%98%E6%89%8B%E8%AF%BE/15%20%E5%AE%B9%E5%99%A8%E7%BD%91%E7%BB%9C%EF%BC%9A%E6%88%91%E4%BF%AE%E6%94%B9%E4%BA%86_proc_sys_net%E4%B8%8B%E7%9A%84%E5%8F%82%E6%95%B0%EF%BC%8C%E4%B8%BA%E4%BB%80%E4%B9%88%E5%9C%A8%E5%AE%B9%E5%99%A8%E4%B8%AD%E4%B8%8D%E8%B5%B7%E6%95%88%EF%BC%9F.md)
        - [TCP KeepAlive机制理解与实践小结 - 博客园](https://www.cnblogs.com/hueyxu/p/15759819.html)
            - 被容器连接的主机也需要设置，通过`sysctl net.ipv4.tcp_keepalive_time`查看，通过`sysctl net.ipv4.tcp_keepalive_time=864000`设置超时时间为10天

## 2.4 注意事项

### 2.4.1 终端字体显示不全or乱码

- 原因：默认的字体符号不全
- 解决：推荐终端使用 [HackNerdFontMono-Regular.ttf](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack/Regular) 字体

### 2.4.2 TensorFlow注意事项

- ① 低版本Tensorflow(1.xx版本)，如果使用runtime镜像，必须使用Conda安装TensorFlow，会自动安装Tensorflow对应版本的cudatoolkit与cudnn
- [完美解决TensorFlow-gpu报错问题Could not load dynamic library ‘libnvinfer.so.6’ and ‘libcudart.so.11.0’_](http://www.4k8k.xyz/article/weixin_41194129/120215865)

```shell
conda search tensorflow-gpu 
conda search tensorflow-gpu --channel conda-forge
# 可尝试是否指定channel为conda-forge，否则可能会找不到gpu的包
conda install -n [your_env_name] -y tensorflow-gpu==1.xxx -c conda-forge
# 清除下载包，占用空间较大
conda clean --all -y --verbose
```

- ② 高版本Tensorflow(2.xx版本) ，使用GPU异常，直接使用devel镜像，而不是runtime
- [FIx for "Couldn't invoke ptxas --version" with cuda-11.3 and jaxlib 0.1.66+cuda111](https://github.com/google/jax/discussions/6843)
- ==**注意**==：建议根据[TensorFlow与Cuda的版本对应关系](https://www.tensorflow.org/install/source#gpu)，选择相应版本的cuda的**devel**镜像

## 2.5 更多容器配置

### 2.5.1 推荐Volume映射

```yaml
services:
  【名字拼音缩写，如lx】_train:
    volumes:
      - ${CODE_DIR}:/home/appuser/Workspace
      # 下面的文件，① 先启动容器，将文件复制出来(docker cp 容器名:容器内路径 ./)，② 然后再添加volume映射
      - ${VOLUME_DIR}/miniforge:/home/appuser/Software/miniforge
      - ${VOLUME_DIR}/supervisor:/etc/supervisor
      - ${VOLUME_DIR}/.cache:/home/appuser/.cache
      - ${VOLUME_DIR}/.zsh_history:/home/appuser/.zsh_history
      # ③ 映射完毕，在容器内将文件的owner改为容器的普通用户: sudo chown -R appuser: ~/Software/miniforge ~/.cache ~/.zsh_history ~/Workspace
```

### 2.5.2 用户密码设置

```yaml
services:
  【名字拼音缩写，如lx】_train:
    secrets: # 启动容器时自动修改密码
      - root_password
      - user_password

secrets:
  root_password:
    file: ${VOLUME_DIR}/secrets/root_password.txt
  user_password:
    file: ${VOLUME_DIR}/secrets/user_password.txt
```

### 2.5.3 host映射

容器内直接通过域名访问其他GPU机器，防止其他机器IP变动

```yaml
services:
  【名字拼音缩写，如lx】_train:
    extra_hosts:
      - "gpu1.wedoctor.server:host-gateway" # 当前主机
      - "gpu2.wedoctor.server:192.168.3.28" # 其他主机
```

### 2.5.4 容器中安装Oracle的Python客户端依赖

```shell
mkdir -p /opt/oracle
cd /opt/oracle
wget https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip
unzip instantclient-basic-linux.x64-21.6.0.0.0dbru.zip
apt-get install libaio-dev -y
sh -c "echo /opt/oracle/instantclient_21_6 > /etc/ld.so.conf.d/oracle-instantclient.conf"
ldconfig
```

# 3 归档问题

## 3.1 command not found: print_icon问题

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

- ~~原因：在于Windows的工具改了默认的locale~~
- ~~解决：在镜像构建中~~
    - ~~`apt install language-pack-en`~~
    - ~~[icons.zsh:168: character not in range](https://github.com/Powerlevel9k/powerlevel9k/issues/639)~~
- 最终解决
    - 已通过设置`LC_ALL`解决

## 3.2 Why can't I run command “nvcc --version" in docker-CUDA Container?

- 使用devel替代runtime
- [Why can't I run command “nvcc --version" in docker-CUDA Container?](https://github.com/NVIDIA/nvidia-docker/issues/1160)

## 3.3 supervisor经常出现错误日志

- 问题：使用`docker logs -f xxxd`可看出如下错误日志：
- ```
  2025-04-22 15:28:37,588 INFO reaped unknown pid 96743 (exit status 1)
  2025-04-22 15:28:38,917 INFO reaped unknown pid 96836 (exit status 1)
  2025-04-22 15:28:38,917 INFO reaped unknown pid 96840 (exit status 0)
  ```
- 原因
    - [What does "reaped" mean in Supervisord logs?](https://www.reddit.com/r/devops/comments/ooq32r/what_does_reaped_mean_in_supervisord_logs/)
    - 是docker-compose的健康检查造成的，在容器中使用`supervisorctl status`可复现
- 该问题可忽略
