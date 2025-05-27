# 基础环境

## 换源

Ubuntu/Debain

```bash
wget https://linuxmirrors.cn/main.sh
chmod +x main.sh
./main.sh
```

[完美解决 bash: /dev/fd/63: No such file or directory](https://blog.csdn.net/jiahaoangle/article/details/106475891)

## 时区修改

[ntpdate](https://www.iplaysoft.com/tools/linux-command/c/ntpdate.html)

```shell
timedatectl set-timezone Asia/Shanghai
timedatectl
apt install -y ntpdate  / yum install -y ntpdate

# -b	通过调用 settimeofday 子例程来增加时钟的时间
# -d	指定调试方式。判断 ntpdate 命令会产生什么结果（不产生实际的结果）。结果再现在屏幕上。这个标志使用无特权的端口。
# -u	指定使用无特权的端口发送数据包。 当在一个对特权端口的输入流量进行阻拦的防火墙后是很有益的， 并希望在防火墙之外和主机同步。防火墙是一个系统或者计算机，它控制从外网对专用网的访问。
ntpdate -u ntp.aliyun.com

# 可读取BIOS中的时间
hwclock -r
# 将当前系统时间写入BIOS
hwclock -w
```

## 基础软件

### Ubuntu / Debain

```bash
apt update -y && apt upgrade -y
apt install -y vim
apt install -y git telnet iputils-ping net-tools tree
apt install -y wget curl rsync
apt install -y zip unzip
apt install -y neofetch htop

#  apt install python3.10
apt install -y python3-pip

pip config set global.index-url https://mirrors.cloud.tencent.com/pypi/simple
pip config set global.extra-index-url https://mirrors.cloud.tencent.com/pypi/simple

# python3.10 -m pip --version
pip3 install gpustat

# glances
pip3 install glances

# nvitop
pip3 install nvitop

apt autoremove
apt autoclean
```

### Debian

若使用Debain出现以下问题，可参照解决

[debain vi上下左右变ABCD问题解决方法](https://blog.csdn.net/xc_zhou/article/details/102488044)

[debian终端tab键无法补全命令，apt install 无法补全](https://blog.csdn.net/OceanWaves1993/article/details/113926061)

## Docker

① 安装

https://linuxmirrors.cn/other/

```bash
bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
```

开机启动

```
systemctl enable docker.service
systemctl restart docker.service
```

② 修改配置：` vim /etc/docker/daemon.json`

```json
{
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "50m",
		"max-file": "3"
	},
	"registry-mirrors": [
		"https://dockerproxy.com",
		"https://registry.cn-hangzhou.aliyuncs.com",
		"https://ccr.ccs.tencentyun.com",
		"https://mirror.baidubce.com"
	],
	"dns": [
		"223.5.5.5",
		"1.1.1.1"
	],
	"default-address-pools": [{
		"base": "172.0.0.0/8",
		"size": 16
	}]
}
```

```bash
systemctl restart docker.service
```

④ 镜像导入

```shell
# gpu-train-49机器
# docker save -o alg.tar alg:cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh
scp /workspace/user/lx/alg.tar root@虚拟机IP:/root    # 复制镜像到虚拟机

docker load < alg.tar
docker images
```

⑤ 安装Docker Compose：[Install Compose standalone](https://docs.docker.com/compose/install/standalone/)

```shell
# 如果下载慢可使用自己的电脑下载，再上传
curl -SL https://mirror.ghproxy.com/https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

docker-compose --version
```

# Nvidia驱动

## 驱动安装

==先安装dkms，装驱动的过程中使用dkms==

```shell
apt install -y dkms  / yum install -y dkms
dkms status # 理论上无任何信息
```

**nvidia-detect**

```shell
apt install -y nvidia-detect
nvidia-detect # 理论上应该有显卡信息
```

Debain：[How to Install Nvidia Drivers on Debian](https://phoenixnap.com/kb/nvidia-drivers-debian#ftoc-heading-5)

**前置系统环境要求**

1. 保证只有一个内核
    - [debian/Ubuntu/centos删除多余内核](https://www.idceval.com/79.html)
    - [Linux内核卸载和禁止更新](https://www.cnblogs.com/youpeng/p/11219485.html)

```shell
# 先重启，必须。因为可能已经更新内核，还未生效
reboot

# 查看当前的内核
uname -sr

# 查看已安装的内核。若有多个需要删除
dpkg -l | grep linux-image | awk '{print$2}'

# 一键删除未使用的内核
apt -y remove --purge $(dpkg -l | grep linux-image | awk '{print$2}' | grep -v $(uname -r)) 

# 再次查看已安装的内核
dpkg -l | grep linux-image | awk '{print$2}'

# 更新引导系统并重启
update-grub
reboot
```

2. 关闭nouveau

```shell
vim /etc/modprobe.d/blacklist-nouveau.conf
# 写入下面内容 ————begain————
blacklist nouveau
options nouveau modeset=0
# 写入下面内容 ————end————

update-initramfs -u
reboot

lsmod | grep nouveau # 验证nouveau是否已禁用。已禁用无任何输出
```

3. 装驱动的依赖

```shell
apt install -y linux-headers-$(uname -r) build-essential libglvnd-dev pkg-config
```

**下载驱动安装**

```shell
# 如果安装过驱动，先卸载已安装驱动
# nvidia-uninstall 或者 ./NVIDIA-Linux-x86_64-470.223.02.run  --uninstall
# apt remove --purge nvidia*
# reboot

# 470版本。A40使用这个
wget https://cn.download.nvidia.com/tesla/470.223.02/NVIDIA-Linux-x86_64-470.223.02.run
chmod +x NVIDIA-Linux-x86_64-470.223.02.run
# -no-x-check：安装驱动时关闭X服务
# -no-nouveau-check：安装驱动时禁用nouveau
# -no-opengl-files：只安装驱动文件，不安装OpenGL文件
./NVIDIA-Linux-x86_64-470.223.02.run -no-x-check -no-nouveau-check -no-opengl-files # 安装过程中的选项查看下面的安装信息

# 查看是否有安装的错误日志。比如明显的error、fail之类
cat /var/log/nvidia-installer.log
```

**安装过程信息**

```shell

  Would you like to register the kernel module sources with DKMS? This will allow DKMS to automatically build a new module, if you install a different kernel later.

                    Yes ✓                           No


  WARNING: nvidia-installer was forced to guess the X library path '/usr/lib' and X module path '/usr/lib/xorg/modules'; these paths were not queryable from the system.  If X fails to find the NVIDIA X driver module, please install the `pkg-config` utility and the X.Org SDK/development package for your
           distribution and reinstall the driver.

                    OK ✓


 Install NVIDIA's 32-bit compatibility libraries?

                 Yes                              No ✓


  Installation of the kernel module for the NVIDIA Accelerated Graphics Driver for Linux-x86_64 (version 470.223.02) is now complete.

                 OK ✓
```

```shell
reboot
dkms
nvidia-smi # 可以看到有显卡
```

## 烤机脚本

### 容器环境

部署训练容器

```shell
cd  ~/deploy_test
vim ~/deploy_test/docker-compose.yaml # 填入下面内容
docker-compose up -d # 出现错误见下面文档
```

```yaml
version: "3.8"

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "10"

services:
  test_train:
    container_name: "test_train"
    image: alg:cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh   # 【自定义镜像版本】
    restart: unless-stopped
    environment:
      SSH_PASSWORD: ewell123        #【自定义SSH密码】
    ports:
      - "1022:22"    # 【自定义SSH端口映射】
      - "18080:8080" # 【自定义WEB端口映射，方便容器中WEB服务的调试】
    volumes:
      - /workspace/user/test/code:/workspace
    healthcheck:
      test: ["CMD", "supervisorctl", "status"]
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

若提示下面错误，应该安装`nvidia-container-toolkit`

```
Error response from daemon: could not select device driver "nvidia" with capabilities: [[gpu]]
```

[Installing the NVIDIA Container Toolki](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

```shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update

apt install -y nvidia-container-toolkit

systemctl restart docker
```

### Conda环境

```shell
ssh root@127.0.0.1 -p 1022  # 如果失败将127.0.0.1改成主机IP
# ewell123

nvidia-smi # 可以看到有显卡信息输出
```

```shell
conda create -y -n torch_cpu python=3.10
conda activate torch_cpu
pip3 install torch --index-url https://download.pytorch.org/whl/cpu
pip install tqdm numpy

conda create -y -n torch_gpu python=3.10
conda activate torch_gpu
pip3 install torch --index-url https://download.pytorch.org/whl/cu118
pip install tqdm numpy
```

脚本运行

```shell
cd /workspace/ewell_mednlp_tools/src/test/test_gpu
# rm -rf ./*.log

# 测试CPU。可不运行
conda activate torch_cpu
nohup python -u test_cpu.py >> run_cpu_torch.log 2>&1 &

# 测试GPU
conda activate torch_gpu
nohup python -u test_gpu_torch.py >> run_gpu_torch.log 2>&1 &

```

```bash
# 在主机（非容器），使用此命令查看程序的GPU占用情况
# 出现GPU UTL: 100.0% 为成功，GPU MEM占用率低没关系
nvitop
```

