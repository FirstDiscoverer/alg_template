# 基本信息

第一次安装：物理机CentOS 7.9

第二次安装：物理机ESXI7 + 虚拟机Ubuntu 22.04 LTS。不行，系统必须LVM，运维说不行

第三次安装：物理机ESXI7 + 虚拟机Debian 11

**系统版本需要满足两个条件**：① Docker支持、② Nvidia驱动支持

**==注意==：**

- 运维交付系统后，重启查看syslog和kern.log是否存在error或者fail
- 原物理机 CPU110多核，内存256G，存储15T。电源1300w，全部使用所有资源可能存在问题，散热跟不上（运维说的），所以虚拟机做了资源限制

# 基础环境

## 1 网络

**CentOS 7**

```bash
# 修改DNS
vim /etc/sysconfig/network-scripts/ifcfg-en
systemctl restart network
cat /etc/resolv.conf
```

第一个DNS为公司DNS

```
DNS1=192.168.151.5
DNS2=223.5.5.5
DNS3=1.1.1.1
```

**Ubuntu**

~~[Ubuntu修改DNS方法（临时和永久修改DNS）](https://www.laozuo.org/25628.html)~~

[ubuntu 22.04如何配置静态IP、网关、DNS](https://www.cnblogs.com/liujiaxin2018/p/16287463.html)

[Ubuntu20和22的 /etc/netplan/*.yaml 一些配置静态IP的文件收集](https://juejin.cn/post/7154864473050710046)

[Ubuntu22.04网络配置](https://juejin.cn/post/7139049944903581732)

```shell
cd /etc/netplan/
ls

vim xxx
# 修改nameservers下的addresses
sudo netplan apply

cat /etc/resolv.conf
```

**Debian**

方法一：

[debian如何修改服务器DNS](https://worktile.com/kb/ask/1123186.html)

```shell
vim /etc/network/interfaces

# 修改 dns-nameservers 223.5.5.5 1.1.1.1

reboot

cat /etc/resolv.conf
```

方法二：

[Debian 11 修改 DNS 服务器](https://zhuanlan.zhihu.com/p/521596491)

```shell
vim /etc/dhcp/dhclient.conf

# 添加
supersede domain-name-servers 223.5.5.5, 1.1.1.1;

reboot

cat /etc/resolv.conf
```

## 2 换源

Centos

```shell
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

Ubuntu/Debain

```
wget https://linuxmirrors.cn/main.sh
chmod +x main.sh
./main.sh
```

[完美解决 bash: /dev/fd/63: No such file or directory](https://blog.csdn.net/jiahaoangle/article/details/106475891)

## 3 时区修改

[ntpdate](https://www.iplaysoft.com/tools/linux-command/c/ntpdate.html)

```shell
timedatectl set-timezone Asia/Shanghai
timedatectl
yum install -y ntpdate   / apt install -y ntpdate

# -b	通过调用 settimeofday 子例程来增加时钟的时间
# -d	指定调试方式。判断 ntpdate 命令会产生什么结果（不产生实际的结果）。结果再现在屏幕上。这个标志使用无特权的端口。
# -u	指定使用无特权的端口发送数据包。 当在一个对特权端口的输入流量进行阻拦的防火墙后是很有益的， 并希望在防火墙之外和主机同步。防火墙是一个系统或者计算机，它控制从外网对专用网的访问。
ntpdate -u ntp.aliyun.com

# 可读取BIOS中的时间
hwclock -r
# 将当前系统时间写入BIOS
hwclock -w
```

## 4 基础软件

### CentOS 7

```shell
yum update -y && yum upgrade -y
yum install -y vim
yum install -y git telnet iputils net-tools tree
yum install -y wget curl
yum install -y zip unzip
yum install -y htop
```

- neofetch

  ```shell
  curl -o /etc/yum.repos.d/konimex-neofetch-epel-7.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo
  yum install -y neofetch
  ```

- glances

  ```shell
  yum install -y python3
  pip --version
  pip3 --version
  python3 -m pip install --upgrade pip -i https://mirrors.cloud.tencent.com/pypi/simple # 看上面版本情况是否执行
  curl -L https://bit.ly/glances | /bin/bash
  ```

- ctop：[bcicen/ctop](https://github.com/bcicen/ctop/)

```shell
# sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
wget https://mirror.ghproxy.com/https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop
```

① 使用最新版本Git

[CentOS 7 升级 git 版本到 2.x](https://juejin.cn/post/7071910670056292389)

```shell
git --version
yum remove git
yum remove git-*

yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
yum install -y git
git --version
```

### Ubuntu / Debain

```bash
apt update -y && apt upgrade -y
apt install -y vim
apt install -y git telnet iputils-ping net-tools tree
apt install -y wget curl rsync
apt install -y zip unzip
apt install -y neofetch htop

apt install -y python3-pip
pip config set global.index-url https://mirrors.cloud.tencent.com/pypi/simple
pip config set global.extra-index-url https://mirrors.cloud.tencent.com/pypi/simple
pip3 install gpustat

# glances
pip3 install glances

# nvitop
pip3 install nvitop

apt autoremove
apt autoclean
```

- ctop：[bcicen/ctop](https://github.com/bcicen/ctop/)

### Debian

[debain vi上下左右变ABCD问题解决方法](https://blog.csdn.net/xc_zhou/article/details/102488044)

[debian终端tab键无法补全命令，apt install 无法补全](https://blog.csdn.net/OceanWaves1993/article/details/113926061)

### 通用

[cheat/cheat](https://github.com/cheat/cheat/blob/master/INSTALLING.md)

```shell
alias cheat='docker run --rm bannmann/docker-cheat'
```

## 5 修改主机名

```shell
hostnamectl set-hostname --static xxx
```

## 6 ZSH

**个人自已使用ZSH**

```shell
echo $0
cat /etc/shells
yum install -y zsh  / apt install -y zsh
chsh -s /bin/zsh
# 重新登录，选择2 创建.zshrc文件
```

`vim ~/.zshrc`，添加以下内容

```
alias grep="grep -i --color=auto"
alias l="ls -lF"
alias ll="ls -alF"
alias gpu_info='watch -n1 --color "gpustat -cpu --color"'

alias d=docker
alias d_ps_name='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"'
docker_stop_exit() { docker stop $(docker ps -a | grep "Exited" | awk '{print $1}') }
docker_rm_exit() { docker rm $(docker ps -a | grep "Exited" | awk '{print $1}') }
docker_rmi_none() { docker rmi $(docker images | grep "none" | awk '{print $3}') }
docker_rmi_dangling() { docker rmi $(docker images -f "dangling=true" -q) }

alias work_dir='cd /workspace/user/$USER'
work_dir

neofetch
```

[SSHing into system with ZSH as default shell doesn't run /etc/profile](https://unix.stackexchange.com/questions/537637/sshing-into-system-with-zsh-as-default-shell-doesnt-run-etc-profile)

## 7 Docker

① 安装

方法一：https://linuxmirrors.cn/other/

方法二：[Docker CE 软件仓库](https://mirrors.bfsu.edu.cn/help/docker-ce/)

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
  "default-address-pools": [
    {
      "base": "172.200.0.0/16",
      "size": 32
    }
  ]
}
```

③ 修改数据目录

```shell
# workspace数据放在固态硬盘上
mkdir /home/workspace
ln -s /home/workspace /workspace

# workspace数据从固态硬盘迁移到机械盘
systemctl stop docker
mv /data/workspace /data/workspace-need_rm
cp -R /home/workspace-need_rm /data/
mv /data/workspace-need_rm /data/workspace
ln -s /data/workspace /workspace

systemctl restart docker
```

```shell
# docker数据修改
systemctl stop docker
cp -a /var/lib/docker /workspace/docker/root_dir
ln -s /workspace/docker/root_dir /var/lib/docker
ls -al /var/lib | grep docker
systemctl restart docker
docker info | grep -i root
```

④ 镜像倒入

```shell
docker save -o alg.tar alg:cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh
docker load < alg.tar
```

⑤ 安装Docker Compose：

- [Install Compose standalone](https://docs.docker.com/compose/install/standalone/)

```shell
# 如果下载慢可使用自己的电脑下载，再上传
curl -SL https://mirror.ghproxy.com/https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

docker-compose --version
```

- [Install the plugin manually](https://docs.docker.com/compose/install/linux/#install-the-plugin-manually)

```shell
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
# curl -SL https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
curl -SL https://mirror.ghproxy.com/https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
docker compose version
```

⑥ 测试GPU

若提示下面错误，应该安装`nvidia-container-toolkit`

```
Error response from daemon: could not select device driver "nvidia" with capabilities: [[gpu]]
```

[Installing the NVIDIA Container Toolki](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

```shell
# 源见上面链接
sudo apt install -y nvidia-container-toolkit
```

[Centos7安装nvidia-container-toolkit](https://developer.aliyun.com/article/767168)

```shell
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
yum install -y nvidia-container-toolkit
systemctl restart docker
```

## 8 用户

```shell
useradd -m 用户名
passwd 用户名
# ewell123456

vim /etc/sudoers
# 在 root ALL=(ALL) ALL 下面添加 用户名 ALL=(ALL) ALL

# 添加Docker用户
cat /etc/group | grep docker
usermod -aG docker 用户名
```

**目录初始化**

```shell
ln -s /data/workspace /workspace

mkdir /workspace/user
mkdir /workspace/data_share
mkdir -p /workspace/docker/common
mkdir /workspace/backup

cd /workspace

chmod_workspace_dir() {
	chmod a+rxw /workspace/user

	chmod a+rxw -R /workspace/backup \
		/workspace/data_share \
		/workspace/docker/common \
		/workspace_ssd/docker/common
}
```

# 启动脚本

## CentOS 7

[CentOS7开机自动执行脚本](https://blog.csdn.net/github_38336924/article/details/112304663)

添加脚本权限(CentOS 7)

```shell
chmod +x /etc/rc.d/rc.local
vim /etc/rc.d/rc.local

```

## Ubuntu

[ubuntu20.4 rc.local不运行解决办法](https://www.ithb.vip/ubuntu20-4-rc-local-bu-yun-xing-jie-jue-ban-fa.html)

```shell
sudo vim /lib/systemd/system/rc-local.service

# 添加下面内容
[Install]
WantedBy=multi-user.target
Alias=rc-local.service

sudo ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service


sudo touch /etc/rc.local

sudo chmod 755 /etc/rc.local

sudo vim /etc/rc.local

# 添加下面内容。需要首行无空行
#!/bin/bash
echo $(date) start >> /var/log/rc-local.log


echo $(date) end >> /var/log/rc-local.log
exit 0


sudo reboot
sudo systemctl restart rc-local
```

## 内容

```shell
# 更新时间
ntpdate -u ntp.aliyun.com

# 显卡的持久守护进程，暂时不使用
# nvidia-persistenced --user root
```

# 定时任务

[crontab时间计算](https://tool.lu/crontab/)

```shell
systemctl status crond
systemctl enable crond
systemctl restart crond
```

`vim /etc/crontab`

```shell
# 每隔半小时更新时间
*/30 *  *  *  * root       ntpdate -u ntp.aliyun.com
```

重启服务

```shell
systemctl restart crond
systemctl status crond
```

# Nvidia驱动

## 驱动安装

### 驱动下载

[Supported Drivers and CUDA Toolkit Versions](https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers)
，根据`Table 2. CUDA and Drivers`确定LTS版本号

[驱动下载地址](https://www.nvidia.com/Download/Find.aspx)

**历史版本**

- 国内
    - [Linux AMD64 Display Driver Archive](https://www.nvidia.cn/drivers/unix/linux-amd64-display-archive/)
- 国外
    - [Index of /XFree86/Linux-x86_64](https://download.nvidia.com/XFree86/Linux-x86_64/)
    - [Linux AMD64 Display Driver Archive](https://www.nvidia.com/en-us/drivers/unix/linux-amd64-display-archive/)

### 驱动依赖

==先安装dkms，装驱动的过程中使用dkms==

```shell
apt install -y dkms  / yum install -y dkms
dkms status
nvidia-smi
```

**nvidia-detect**

```shell
apt install -y nvidia-detect
nvidia-detect
```

下载驱动安装。在安装前需要进行一些步骤，可见下面不同系统的安装中链接

```shell
sudo apt-get remove --purge nvidia-*

# 535。不使用。A40存在问题
wget https://cn.download.nvidia.com/tesla/535.129.03/NVIDIA-Linux-x86_64-535.129.03.run
sudo ./NVIDIA-Linux-x86_64-535.129.03.run -no-x-check -no-nouveau-check -no-opengl-files
sudo ./NVIDIA-Linux-x86_64-535.129.03.run --uninstall

# 470
wget https://cn.download.nvidia.com/tesla/470.223.02/NVIDIA-Linux-x86_64-470.223.02.run
sudo ./NVIDIA-Linux-x86_64-470.223.02.run -no-x-check -no-nouveau-check -no-opengl-files
```

### CentOS

#### 安装

**==DKMS==**

[最小化 CentOS7.9 操作系统上安装 NVIDIA GPU 驱动](https://blog.qiql.net/archives/nvidiagpu)

#### 问题

##### 显卡不定时会掉

[踩坑nvidia driver](https://zhuanlan.zhihu.com/p/521581269)

**方法一**：persistence模式

[nvidia-smi启动慢，设置persistence，开机启动以及临时启动](https://blog.csdn.net/qq_40947610/article/details/124882362)

https://forums.developer.nvidia.com/t/setting-up-nvidia-persistenced/47986/4

新的persistence-mode

https://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-mode

https://docs.nvidia.com/deploy/driver-persistence/index.html#usage

结果：上述方法无效

------



方法二：rpm方式重装

```shell
wget https://cn.download.nvidia.com/tesla/535.129.03/nvidia-driver-local-repo-rhel7-535.129.03-1.0-1.x86_64.rpm

```

[nvidia-smi show ERR! 问题修复](https://www.cnblogs.com/lif323/p/17129498.html)

` /usr/bin/nvidia-uninstall`

[CentOS.7卸载与安装Nvidia Driver](https://blog.csdn.net/Aaron_qinfeng/article/details/106939938)

[Centos7 安装GPU驱动（rpm包方式安装） 亲测](https://blog.csdn.net/llm765800916/article/details/110195965)

[rpm驱动安装](https://blog.csdn.net/yaohaishen/article/details/112311923)

```
dmesg | grep error
```

```
 lx@gpu-deploy  /workspace/user/lx  dmesg | grep error                                                                  ✔  ⚙  106  17:13:55
[    3.919647] ERST: Error Record Serialization Table (ERST) support is initialized.
[    4.263675] BERT: Boot Error Record Table support is disabled. Enable it by using bert_enable as kernel parameter.
[   18.134731] NVRM objClInitPcieChipset: *** Chipset Setup Function Error!
[ 1883.126247] NVRM: Rate limiting GSP RPC error prints for GPU at PCI:0000:4b:00 (printing 1 of every 30).  The GPU likely needs to be reset.
```

[Intermittent “No devices were found” on CentOS 7 ](https://forums.developer.nvidia.com/t/intermittent-no-devices-were-found-on-centos-7/197288)

```shell
dmesg | grep -i NVRM
```

https://forums.developer.nvidia.com/t/failing-to-load-nvidia-driver/221166

```shell
dmesg | grep -e nvidia -e gpu
```

[Open-source kernel modules are not working](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/433)

```shell
echo "options nvidia NVreg_OpenRmEnableUnsupportedGpus=1" | sudo tee /etc/modprobe.d/nvreg_fix.conf > /dev/null
```

结果：无效，更改操作系统为Ubuntu试试

#### 测试

[GPU性能的简单测试脚本（pytorch版）](https://blog.csdn.net/qq_41129489/article/details/126596108)

|           环境            |      驱动版本      |                            镜像                             |   例子    |      其他      | 是否成功 | 测试人 |                              备注                              |
|:-----------------------:|:--------------:|:---------------------------------------------------------:|:-------:|:------------:|:----:|-----|:------------------------------------------------------------:|
| Pytorch 2.1.0+cu118 (新) | 510.73.05 (旧)  | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  |      -       |  ✓   | L   |                              -                               |
| Pytorch 2.1.0+cu118 (新) | 535.129.03 (新) | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  |      -       |  ✓   | L   |                              -                               |
|                         |                |                                                           |         |              |      |     |                                                              |
|   Tensorflow 2.14 (新)   | 535.129.03 (新) | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  |      -       |  ✓   | D   |                              -                               |
|                         |                |                                                           |         |              |      |     |                                                              |
|   Tensorflow 1.14 (旧)   | 510.73.05 (旧)  | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  | conda PY 3.6 |  ✓   | D   |                              -                               |
|   Tensorflow 1.14 (旧)   | 510.73.05 (旧)  | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  | conda PY 3.7 |  ✗   | D   |                              -                               |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  | conda PY 3.7 |  ✓   | D   |                              -                               |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | 矩阵乘法运算  | conda PY 3.7 |  ✗   | D   |                              -                               |
|                         |                |                                                           |         |              |      |     |                                                              |
|   Tensorflow 1.14 (旧)   | 510.73.05 (旧)  |  cuda10.0-cudnn7-devel-ubuntu18.04-miniconda-ssh-zsh (旧)  | MGP-RNN | conda PY 3.7 |  ✓   | L   |                              -                               |
|   Tensorflow 1.14 (旧)   | 510.73.05 (旧)  |  cuda10.0-cudnn7-devel-ubuntu18.04-miniconda-ssh-zsh (旧)  | MGP-RNN | conda PY 3.7 |  ✗   | D   |                       可能是驱动有问题，理论应该成功                        |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) |  cuda10.0-cudnn7-devel-ubuntu18.04-miniconda-ssh-zsh (旧)  | MGP-RNN | conda PY 3.7 |  ✓   | L   |                              -                               |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) |  cuda10.0-cudnn7-devel-ubuntu18.04-miniconda-ssh-zsh (旧)  | MGP-RNN | conda PY 3.7 |  ✓   | L   |                              -                               |
|                         |                |                                                           |         |              |      |     |                                                              |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | MGP-RNN | conda PY 3.7 |  ✓   | L   |                              -                               |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) | cuda11.8.0-cudnn8-devel-ubuntu22.04-miniconda-ssh-zsh (新) | MGP-RNN |  pip PY 3.7  |  ✓   | L   |                              -                               |
|     535.129.03 (新)      | 535.129.03 (新) |  cuda10.0-cudnn7-devel-ubuntu18.04-miniconda-ssh-zsh (旧)  | MGP-RNN |  pip PY 3.6  |  ✗   | L   |                    CPU->GPU Memcpy failed                    |
|   Tensorflow 1.14 (旧)   | 535.129.03 (新) |  cuda10.0-cudnn7-devel-ubuntu18.04-miniconda-ssh-zsh (旧)  | MGP-RNN |  pip PY 3.7  |  ✗   | L   | failed to run cuBLAS routine: CUBLAS_STATUS_EXECUTION_FAILED |
|                         |                |                                                           |         |              |      |     |                                                              |

**注意**

- 驱动510.73.05为国软服务器驱动版本，为了测试MGP-RNN不能运行安装的。
- 之前运行失败可能是驱动有问题，重装后没有问题

**结论**

- Tensorflow 1.14 ：必须是conda安装TF，cuda10、cuda11.8(驱动535)环境测试成功
    - MGP-RNN：在国软调用GPU不会等待，在新的GPU会等待。（第二次运行就不会等待，`rm -rf ~/.nv`后也会等待）
- Tensorflow 2.14：在最新版(cuda11.8、驱动535)的环境成功运行
- Pytorch 2.1：在最新版(cuda11.8、驱动535)的环境成功运行

### Ubuntu

#### 安装

**==DKMS==**

[ubuntu22.04安装显卡驱动+cuda+cudnn](https://blog.csdn.net/qq_49323609/article/details/130310522) **使用这个**

[Ubuntu18-22.04安装和干净卸载nvidia显卡驱动——超详细、最简单](https://blog.csdn.net/Perfect886/article/details/119109380)

**安装过程信息**

```

  An alternate method of installing the NVIDIA driver was detected. (This is usually a package provided by your
  distributor.) A driver installed via that method may integrate better with your system than a driver installed by
  nvidia-installer.

  Please review the message provided by the maintainer of this alternate installation method and decide how to
  proceed:

                              Continue installation✓                   Abort installation




 The NVIDIA driver provided by Ubuntu can be installed by launching the "Software & Updates" application, and by
 selecting the NVIDIA driver from the "Additional Drivers" tab.





  WARNING: nvidia-installer was forced to guess the X library path '/usr/lib' and X module path
           '/usr/lib/xorg/modules'; these paths were not queryable from the system.  If X fails to find the NVIDIA X
           driver module, please install the `pkg-config` utility and the X.Org SDK/development package for your
           distribution and reinstall the driver.






Install NVIDIA's 32-bit compatibility libraries?

                                       Yes                                    No✓



  Would you like to register the kernel module sources with DKMS? This will allow DKMS to automatically build a new
  module, if your kernel changes later.

                                       Yes✓                                    No

```

#### 问题

##### 显卡不定时会掉

- 注意：
    - 48机器：低版本驱动(470)，运行一段时间GPU程序后，偶现系统卡死，会导致系统无法开机
        - 长时间烤机：排除电源功率不够问题
        - kern.log 在程序崩溃时发现PCI错误，运维升级pcie驱动
    - 49机器：高版本驱动(535) + 禁止GSP-RM，运行一段时间GPU程序后，不定时会出现掉卡情况
        - 不禁止GSP-RM，会有上面的错误日志
        - `sudo dmesg | grep -i fail`、`sudo dmesg | grep -i error`、` sudo dmesg | grep -i NVRM`、
          `sudo dmesg | grep -e nvidia -e gpu`
          无错误日志
            - 目前开启` Persistence-M`后，再观察。出现Failed to initialize NVM问题，运行上面命令无错误日志。可通过下面的禁用容器内的crgoup方法解决

[[Getting this error code - +0.000038] pci 0000:00:15.3: BAR 13: failed to assign [io size 0x1000]](https://www.reddit.com/r/Ubuntu/comments/ohfti9/getting_this_error_code_0000038_pci_000000153_bar/)

[HELP! GPU Passthrough Issues](https://www.reddit.com/r/vmware/comments/15b8xn4/help_gpu_passthrough_issues/?share_id=tigoEoGC8Ao2FA9t52so9&utm_content=2&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=1)

[验证 Linux 实例是否启用了 UEFI 安全启动](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/verify-uefi-secure-boot.html)

48机器摘除GPU，存在sdb 错误 & PCI错误。运维指出PCI错误可能为系统盘为LVM造成的文件系统错误引起

**48机器**

`cat kern.log | grep -i fail`

```shell
Nov 15 11:00:06 gpu-train kernel: [    8.197175] nvidia: module verification failed: signature and/or required key missing - tainting kernel



Nov 15 11:00:06 gpu-train kernel: [    3.089035] pci 0000:00:16.4: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089038] pci 0000:00:16.5: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089040] pci 0000:00:16.5: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089042] pci 0000:00:16.6: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089044] pci 0000:00:16.6: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089047] pci 0000:00:16.7: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089049] pci 0000:00:16.7: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089051] pci 0000:00:17.0: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089053] pci 0000:00:17.0: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089055] pci 0000:00:17.1: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089057] pci 0000:00:17.1: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089060] pci 0000:00:17.2: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089062] pci 0000:00:17.2: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089064] pci 0000:00:17.3: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089066] pci 0000:00:17.3: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089068] pci 0000:00:17.4: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089070] pci 0000:00:17.4: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089073] pci 0000:00:17.5: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089074] pci 0000:00:17.5: BAR 13: failed to assign [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089077] pci 0000:00:17.6: BAR 13: no space for [io  size 0x1000]
Nov 15 11:00:06 gpu-train kernel: [    3.089078] pci 0000:00:17.6: BAR 13: failed to assign [io  size 0x1000]
```

syslog

```
Nov 15 11:00:06 gpu-train kernel: [    8.197175] nvidia: module verification failed: signature and/or required key missing - tainting kernel

Nov 15 11:00:06 gpu-train multipathd[1530]: sda: failed to get udev uid: No data available
Nov 15 11:00:06 gpu-train kernel: [    0.000000] BIOS-e820: [mem 0x000000000fef6000-0x000000000ff11fff] ACPI data
Nov 15 11:00:06 gpu-train kernel: [    0.000000] BIOS-e820: [mem 0x000000000ff12000-0x000000000ff15fff] ACPI NVS
Nov 15 11:00:06 gpu-train kernel: [    0.000000] BIOS-e820: [mem 0x000000000ff16000-0x00000000bfffffff] usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffc29fff] reserved
Nov 15 11:00:06 gpu-train kernel: [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000203fffffff] usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] NX (Execute Disable) protection: active
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3f3018-0x0e3fb057] usable ==> usable
Nov 15 11:00:06 gpu-train multipathd[1530]: sdb: failed to get udev uid: No data available
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3f3018-0x0e3fb057] usable ==> usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3f0018-0x0e3f2057] usable ==> usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3f0018-0x0e3f2057] usable ==> usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3ed018-0x0e3ef057] usable ==> usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3ed018-0x0e3ef057] usable ==> usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3eb018-0x0e3ec857] usable ==> usable
Nov 15 11:00:06 gpu-train kernel: [    0.000000] e820: update [mem 0x0e3eb018-0x0e3ec857] usable ==> usable

Nov 15 11:00:06 gpu-train multipath: sda: failed to get sysfs uid: Invalid argument
Nov 15 11:00:06 gpu-train multipath: sda: failed to get sgio uid: No such file or directory
Nov 15 11:00:06 gpu-train systemd-udevd[1613]: sda: Process '/usr/bin/unshare -m /usr/bin/snap auto-import --mount=/dev/sda' failed with exit code 1.
Nov 15 11:00:06 gpu-train systemd-udevd[1640]: sdb: Process '/usr/bin/unshare -m /usr/bin/snap auto-import --mount=/dev/sdb' failed with exit code 1.

```

48 reboot

··

```
Nov 16 13:13:43 gpu-train multipathd[1058]: sdb: triggering change event to reinitialize
Nov 16 13:13:43 gpu-train multipath: sdb: failed to get sysfs uid: Invalid argument
Nov 16 13:13:43 gpu-train multipath: sdb: failed to get sgio uid: No such file or directory
Nov 16 13:13:43 gpu-train multipathd[1058]: sdb: failed to get sysfs uid: Invalid argument
Nov 16 13:13:43 gpu-train multipathd[1058]: sdb: failed to get sgio uid: No such file or directory
Nov 16 13:13:43 gpu-train multipathd[1058]: sdb: failed to get path uid
Nov 16 13:13:43 gpu-train multipathd[1058]: uevent trigger error
Nov 16 13:13:48 gpu-train systemd[1]: systemd-timedated.service: Deactivated successfully.
Nov 16 13:13:52 gpu-train multipathd[1058]: sda: not initialized after 3 udev retriggers
Nov 16 13:13:53 gpu-train multipathd[1058]: sda: add missing path
Nov 16 13:13:53 gpu-train multipathd[1058]: sda: failed to get sysfs uid: Invalid argument
Nov 16 13:13:53 gpu-train multipathd[1058]: sda: failed to get sgio uid: No such file or directory
Nov 16 13:13:53 gpu-train multipathd[1058]: sda: no WWID in state "undef
Nov 16 13:13:53 gpu-train multipathd[1058]: ", giving up
Nov 16 13:13:53 gpu-train multipathd[1058]: sda: check_path() failed, removing
Nov 16 13:13:53 gpu-train multipathd[1058]: sdb: not initialized after 3 udev retriggers
Nov 16 13:13:54 gpu-train multipathd[1058]: sdb: add missing path
Nov 16 13:13:54 gpu-train multipathd[1058]: sdb: failed to get sysfs uid: Invalid argument
Nov 16 13:13:54 gpu-train multipathd[1058]: sdb: failed to get sgio uid: No such file or directory
Nov 16 13:13:54 gpu-train multipathd[1058]: sdb: no WWID in state "undef
Nov 16 13:13:54 gpu-train multipathd[1058]: ", giving up
Nov 16 13:13:54 gpu-train multipathd[1058]: sdb: check_path() failed, removing
Nov 16 13:17:01 gpu-train CRON[4464]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)
Nov 16 13:18:14 gpu-train systemd[1]: Starting Download data for packages that failed at package install time...
Nov 16 13:18:14 gpu-train systemd[1]: update-notifier-download.service: Deactivated successfully.
Nov 16 13:18:14 gpu-train systemd[1]: Finished Download data for packages that failed at package install time.
Nov 16 13:18:18 gpu-train dbus-daemon[1460]: [system] Activating via systemd: service name='org.freedesktop.timedate1' unit='dbus-org.freedesktop.timedate1.service' requested by ':1.16' (uid=0 pid=1471 comm="/usr/lib/snapd/snapd " label="unconfined")
Nov 16 13:18:18 gpu-train systemd[1]: Starting Time & Date Service...
Nov 16 13:18:18 gpu-train dbus-daemon[1460]: [system] Successfully activated service 'org.freedesktop.timedate1'
Nov 16 13:18:18 gpu-train systemd[1]: Started Time & Date Service.
Nov 16 13:18:20 gpu-train snapd[1471]: storehelpers.go:773: cannot refresh: snap has no updates available: "core20", "lxd", "snapd"
Nov 16 13:18:48 gpu-train systemd[1]: systemd-timedated.service: Deactivated successfully.
```

49机器。11.16 16:31 重启程序掉的。可能是在运行程序，然后重启虚拟机发生的问题

[最近碰到的Nvidia 4090掉卡的问题](https://www.baifachuan.com/posts/1bae99ca.html)

[踩坑nvidia driver](https://zhuanlan.zhihu.com/p/521581269)

##### A40显卡在高版本驱动的GSP-RM问题

[Timeout waiting for RPC from GSP!](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/446)

他们已经确认 `Xid 119` 这个错误。他们表示 `GSP`
功能是从510版本开始引入的，但目前还没有修复。他们只给出了下面提到的禁用它的方法，或者建议我们将版本降级到<510（例如470），以便更稳定。

49机器

```shell
ewell@gpu-deploy:~$ sudo dmesg | grep error
[ 2656.668251] NVRM: Rate limiting GSP RPC error prints for GPU at PCI:0000:03:00 (printing 1 of every 30).  The GPU likely needs to be reset.
[ 2882.931041] nvidia 0000:03:00.0: loading /lib/firmware/nvidia/535.129.03/gsp_ga10x.bin failed with error -4
[ 2882.931049] nvidia 0000:03:00.0: Direct firmware load for nvidia/535.129.03/gsp_ga10x.bin failed with error -4







ewell@gpu-deploy:~$ sudo dmesg | grep -i NVRM
[    6.060263] NVRM: loading NVIDIA UNIX x86_64 Kernel Module  535.129.03  Thu Oct 19 18:56:32 UTC 2023
[ 2638.641500] NVRM: GPU at PCI:0000:03:00: GPU-7775f835-5e4a-cd4e-363f-3c5afb460b28
[ 2638.641513] NVRM: GPU Board Serial Number: 1320223035733
[ 2638.641516] NVRM: Xid (PCI:0000:03:00): 119, pid=32273, name=nvitop, Timeout waiting for RPC from GPU0 GSP! Expected function 76 (GSP_RM_CONTROL) (0x2080a097 0x490).
[ 2638.641531] NVRM: GPU0 GSP RPC buffer contains function 76 (GSP_RM_CONTROL) and data 0x000000002080a097 0x0000000000000490.
[ 2638.641541] NVRM: GPU0 RPC history (CPU -> GSP):
[ 2638.641545] NVRM:     entry function                   data0              data1              ts_start           ts_end             duration actively_polling
[ 2638.641549] NVRM:      0    76   GSP_RM_CONTROL        0x000000002080a097 0x0000000000000490 0x000609ffebd7f5bd 0x0000000000000000          y
[ 2638.641561] NVRM:     -1    76   GSP_RM_CONTROL        0x000000002080a61d 0x000000000000000c 0x000609ffebc8aa58 0x000609ffebc8ac44    492us
[ 2638.641571] NVRM:     -2    76   GSP_RM_CONTROL        0x000000002080a087 0x000000000000000c 0x000609ffebc8a5d7 0x000609ffebc8a9b5    990us
[ 2638.641579] NVRM:     -3    76   GSP_RM_CONTROL        0x000000002080a087 0x000000000000000c 0x000609ffebc8a0aa 0x000609ffebc8a5ac   1282us
[ 2638.641585] NVRM:     -4    76   GSP_RM_CONTROL        0x000000002080a097 0x0000000000000490 0x000609ffebc897e4 0x000609ffebc8a078   2196us
[ 2638.641591] NVRM:     -5    76   GSP_RM_CONTROL        0x000000002080a61d 0x000000000000000c 0x000609ffebb94cea 0x000609ffebb94ed3    489us
[ 2638.641597] NVRM:     -6    76   GSP_RM_CONTROL        0x000000002080a087 0x000000000000000c 0x000609ffebb948b0 0x000609ffebb94cb0   1024us
[ 2638.641603] NVRM:     -7    76   GSP_RM_CONTROL        0x000000002080a087 0x000000000000000c 0x000609ffebb944b3 0x000609ffebb948a1   1006us
[ 2638.641608] NVRM: GPU0 RPC event history (CPU <- GSP):
[ 2638.641612] NVRM:     entry function                   data0              data1              ts_start           ts_end             duration during_incomplete_rpc
[ 2638.641615] NVRM:      0    4108 UCODE_LIBOS_PRINT     0x0000000000000000 0x0000000000000000 0x000609ffc2a20d47 0x000609ffc2a20d47
[ 2638.641623] NVRM:     -1    4108 UCODE_LIBOS_PRINT     0x0000000000000000 0x0000000000000000 0x000609ffc2a20c16 0x000609ffc2a20c17      1us
[ 2638.641629] NVRM:     -2    4123 GSP_SEND_USER_SHARED_ 0x0000000000000000 0x0000000000000000 0x000609ffc2a201e4 0x000609ffc2a201e4
[ 2638.641635] NVRM:     -3    4098 GSP_RUN_CPU_SEQUENCER 0x000000000000060a 0x0000000000003fe2 0x000609ffc2a0b904 0x000609ffc2a0da75   8561us
[ 2644.661134] NVRM: Xid (PCI:0000:03:00): 119, pid=32273, name=nvitop, Timeout waiting for RPC from GPU0 GSP! Expected function 76 (GSP_RM_CONTROL) (0x2080a087 0xc).
[ 2650.664683] NVRM: Xid (PCI:0000:03:00): 119, pid=32273, name=nvitop, Timeout waiting for RPC from GPU0 GSP! Expected function 76 (GSP_RM_CONTROL) (0x2080a087 0xc).
[ 2656.668251] NVRM: Rate limiting GSP RPC error prints for GPU at PCI:0000:03:00 (printing 1 of every 30).  The GPU likely needs to be reset.
[ 2812.810566] NVRM: Xid (PCI:0000:03:00): 119, pid=32273, name=nvitop, Timeout waiting for RPC from GPU0 GSP! Expected function 10 (FREE) (0x5 0x0).
[ 2887.153037] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x23:0x65:1426)
[ 2887.177743] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2893.352177] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2893.354320] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2893.484610] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2893.486709] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2896.311879] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2896.313948] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2896.440810] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2896.442548] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2899.077071] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2899.079101] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2899.211406] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2899.213255] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2900.411148] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2900.413178] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
[ 2900.542153] NVRM: GPU 0000:03:00.0: RmInitAdapter failed! (0x62:0x40:2393)
[ 2900.544164] NVRM: GPU 0000:03:00.0: rm_init_adapter failed, device minor number 0
ewell@gpu-deploy:~$







ewell@gpu-deploy:~$ sudo dmesg | grep -e nvidia -e gpu
[    5.385197] systemd[1]: Hostname set to <gpu-deploy>.
[    5.940889] nvidia: loading out-of-tree module taints kernel.
[    5.940899] nvidia: module license 'NVIDIA' taints kernel.
[    6.000273] nvidia: module verification failed: signature and/or required key missing - tainting kernel
[    6.015250] nvidia-nvlink: Nvlink Core is being initialized, major device number 236
[    6.016900] nvidia 0000:03:00.0: enabling device (0000 -> 0002)
[    6.067888] nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  535.129.03  Thu Oct 19 18:42:12 UTC 2023
[    6.093529] [drm] [nvidia-drm] [GPU ID 0x00000300] Loading driver
[    6.093532] [drm] Initialized nvidia-drm 0.0.0 20160202 for 0000:03:00.0 on minor 1
[    6.281597] audit: type=1400 audit(1699842011.731:4): apparmor="STATUS" operation="profile_load" profile="unconfined" name="nvidia_modprobe" pid=1841 comm="apparmor_parser"
[    6.281605] audit: type=1400 audit(1699842011.731:5): apparmor="STATUS" operation="profile_load" profile="unconfined" name="nvidia_modprobe//kmod" pid=1841 comm="apparmor_parser"
[   38.775380] nvidia_uvm: module uses symbols from proprietary module nvidia, inheriting taint.
[   38.781212] nvidia-uvm: Loaded the UVM driver, major device number 234.
[ 2638.641700]  os_dump_stack+0xe/0x14 [nvidia]
[ 2638.642671]  _nv011587rm+0x328/0x390 [nvidia]
[ 2638.644370] 000000009ec70e9c: ffffffffc17c9188 (_nv011587rm+0x328/0x390 [nvidia])
[ 2638.646050] 000000004d7d224f: ffffffffc17c9188 (_nv011587rm+0x328/0x390 [nvidia])
[ 2638.647782] 000000008043d765: ffffffffc1d82c57 (os_dump_stack+0xe/0x14 [nvidia])
[ 2638.648655] 000000004f303f6d: ffffffffc17c9188 (_nv011587rm+0x328/0x390 [nvidia])
[ 2638.650329] 00000000d9316387: ffffffffc1a647a3 (_nv011507rm+0x73/0x340 [nvidia])
[ 2638.651761] 000000006d4fa473: ffffffffc1a89494 (_nv043992rm+0x4b4/0x6e0 [nvidia])
[ 2638.653122] 00000000f5d2b931: ffffffffc12c9053 (_nv000691rm+0x133/0x2a0 [nvidia])
[ 2638.653424] 00000000273727cc: ffffffffc12c8f20 (_nv000664rm+0x160/0x160 [nvidia])
[ 2638.653722] 0000000065566037: ffffffffc45784e0 (nv_kthread_q+0x40/0xfffffffffd80bb60 [nvidia])
[ 2638.653965] 0000000004446fe6: ffffffffc1299e3d (_nv011754rm+0x3d/0xa0 [nvidia])
[ 2638.654255] 000000001f39ed65: ffffffffc1c70b61 (_nv000715rm+0x9c1/0xe70 [nvidia])
[ 2638.654581] 00000000389476c0: ffffffffc45784e0 (nv_kthread_q+0x40/0xfffffffffd80bb60 [nvidia])
[ 2638.654826] 0000000054812a1f: ffffffffc1c77788 (rm_ioctl+0x58/0xb0 [nvidia])
[ 2638.655150] 00000000633d314d: ffffffffc45b1130 (_nv042266rm+0x90/0xfffffffffd7d2f60 [nvidia])
[ 2638.655394] 0000000001815965: ffffffffc45784e0 (nv_kthread_q+0x40/0xfffffffffd80bb60 [nvidia])
[ 2638.655642] 00000000296f614d: ffffffffc11eecbd (nvidia_ioctl+0x61d/0x840 [nvidia])
[ 2638.655892] 000000007cfaa073: ffffffffc1201875 (nvidia_frontend_unlocked_ioctl+0x55/0x90 [nvidia])
[ 2638.656202]  ? _nv011507rm+0x73/0x340 [nvidia]
[ 2638.656648]  ? _nv043992rm+0x4b4/0x6e0 [nvidia]
[ 2638.657070]  ? _nv000691rm+0x133/0x2a0 [nvidia]
[ 2638.657367]  ? _nv000664rm+0x160/0x160 [nvidia]
[ 2638.657653]  ? _nv011754rm+0x3d/0xa0 [nvidia]
[ 2638.657931]  ? _nv000715rm+0x9c1/0xe70 [nvidia]
[ 2638.658254]  ? rm_ioctl+0x58/0xb0 [nvidia]
[ 2638.658571]  ? nvidia_ioctl+0x61d/0x840 [nvidia]
[ 2638.658832]  ? nvidia_frontend_unlocked_ioctl+0x55/0x90 [nvidia]
[ 2882.931041] nvidia 0000:03:00.0: loading /lib/firmware/nvidia/535.129.03/gsp_ga10x.bin failed with error -4
[ 2882.931049] nvidia 0000:03:00.0: Direct firmware load for nvidia/535.129.03/gsp_ga10x.bin failed with error -4
ewell@gpu-deploy:~$

```

##### 高版本驱动 容器内偶现 Failed to initialize NVM

情况：49机器；Ubuntu 22.04；高版本驱动(535) + 禁止GSP-RM；持久模式启用； Cgroup Version: 2

[failed call to cuInit: CUDA_ERROR_NO_DEVICE: no CUDA-capable device is detected 排坑指南](https://www.cnblogs.com/roscangjie/p/10744146.html)

容器内再一次运行要调用GPU的程序时，会报错

```shell
2023-11-15 10:31:27.883799: E tensorflow/stream_executor/cuda/cuda_driver.cc:318] failed call to cuInit: CUDA_ERROR_NO_DEVICE: no CUDA-capable device is detected
```

容器内

```shell
 root@d3a6bda33ba3  /workspace/mgp_rnn  nvidia-smi
Failed to initialize NVML: Unknown Error
```

- ["Failed to initialize NVML: Unknown Error" after random amount of time](https://github.com/NVIDIA/nvidia-docker/issues/1671)
    - 我在 Ubuntu 22 上使用 docker-ce，所以我选择了这种方法，到目前为止工作正常。
- [Failed to initialize NVML: Unknown Error in Docker after Few hours](https://stackoverflow.com/questions/72932940/failed-to-initialize-nvml-unknown-error-in-docker-after-few-hours)
    - 原因：主机执行守护程序重新加载（或类似的活动）。如果容器使用 systemd 来管理 cgroup，则 daemon-reload 会“触发重新加载任何引用
      NVIDIA GPU 的单元文件”。然后，您的容器将无法访问重新加载的 GPU 引用。
    - 解决：禁用容器内cgroups

### Debain

#### 安装

[How to Install Nvidia Drivers on Debian](https://phoenixnap.com/kb/nvidia-drivers-debian#ftoc-heading-5)

#### 问题

```shell
nvidia-smi
# 提示no devices were found”


# cat /var/log/messages | grep fail
Apr 16 18:44:05 gpu-test kernel: [    0.439533] pci 0000:13:00.0: BAR 1: failed to assign [mem size 0x1000000000 64bit pref]
Apr 16 18:44:05 gpu-test kernel: [    2.877643] nvidia: module verification failed: signature and/or required key missing - tainting kernel
Apr 16 18:44:05 gpu-test kernel: [    4.959287] NVRM: GPU 0000:13:00.0: RmInitAdapter failed! (0x24:0xffff:1211)
Apr 16 18:44:05 gpu-test kernel: [    4.960096] NVRM: GPU 0000:13:00.0: rm_init_adapter failed, device minor number 0
Apr 16 18:44:05 gpu-test kernel: [    5.158874] NVRM: GPU 0000:13:00.0: RmInitAdapter failed! (0x24:0xffff:1211)
Apr 16 18:44:05 gpu-test kernel: [    5.159538] NVRM: GPU 0000:13:00.0: rm_init_adapter failed, device minor number 0
Apr 16 18:44:16 gpu-test kernel: [   16.443833] NVRM: GPU 0000:13:00.0: RmInitAdapter failed! (0x24:0xffff:1211)
Apr 16 18:44:16 gpu-test kernel: [   16.444586] NVRM: GPU 0000:13:00.0: rm_init_adapter failed, device minor number 0
Apr 16 18:44:16 gpu-test kernel: [   16.647371] NVRM: GPU 0000:13:00.0: RmInitAdapter failed! (0x24:0xffff:1211)
Apr 16 18:44:16 gpu-test kernel: [   16.648097] NVRM: GPU 0000:13:00.0: rm_init_adapter failed, device minor number 0
Apr 16 18:45:00 gpu-test kernel: [   59.890256] NVRM: GPU 0000:13:00.0: RmInitAdapter failed! (0x24:0xffff:1211)
```

- 解决：系统为BIOS引导，改为EFI并且关闭安全引导

- 参考资料

    - [SOLVED - RmInitAdapter failed! to load 530.41.03 (or any nvidia modules other than 450.236.01) Linux via ESXi 7.0u3 Passthrough PCI GTX 1650](https://forums.developer.nvidia.com/t/solved-rminitadapter-failed-to-load-530-41-03-or-any-nvidia-modules-other-than-450-236-01-linux-via-esxi-7-0u3-passthrough-pci-gtx-1650/253239)

    - [VMware ESXi 6.7.0 update2 使用 GPU Passthrough 模式的坑](http://www.singleye.net/2019/07/vmware-esxi-6.7.0-update2-%E4%BD%BF%E7%94%A8-gpu-passthrough-%E6%A8%A1%E5%BC%8F%E7%9A%84%E5%9D%91/)

    - [Nvidia-smi shows “No devices were found”, and dmesg shows “rm_init_adapter failed, device minor number 0”](https://forums.developer.nvidia.com/t/nvidia-smi-shows-no-devices-were-found-and-dmesg-shows-rm-init-adapter-failed-device-minor-number-0/203986)

    - [Nvidia-smi “No devices were found” - VMWare ESXI Ubuntu Server 20.04.03 with RTX3070 Nvidia-smi“未找到设备”-带有 RTX3070 的 VMWare ESXI Ubuntu Server 20.04.03](https://forums.developer.nvidia.com/t/nvidia-smi-no-devices-were-found-vmware-esxi-ubuntu-server-20-04-03-with-rtx3070/202904)

## 烤机脚本

环境准备

```shell
conda config --set custom_channels.nvidia https://mirrors.cernet.edu.cn/anaconda-extra/cloud/

conda create -y -n torch_cpu python=3.10
conda activate torch_cpu
pip3 install torch --index-url https://download.pytorch.org/whl/cpu
pip install tqdm

conda create -y -n torch_gpu python=3.10
conda activate torch_gpu
pip3 install torch --index-url https://download.pytorch.org/whl/cu118
pip install tqdm

conda create -y -n p_mgp_rnn python=3.7
conda activate p_mgp_rnn
conda install tensorflow-gpu==1.14 -y
cd /workspace/mgp_rnn
pip install -r requirements.txt
```

脚本运行

```shell
cd /workspace/ewell_mednlp_tools/test/test_gpu
# rm -rf ./*.log

conda activate torch_cpu
nohup python -u test_cpu.py >> run_cpu_torch.log 2>&1 &

conda activate torch_gpu
nohup python -u test_gpu_torch.py >> run_gpu_torch.log 2>&1 &

cd /workspace/mgp_rnn
# rm -rf ./*.log
conda activate p_mgp_rnn
nohup python -u mgp-rnn-fit.py >> run.log 2>&1 &
```

# 服务器问题

## 掉显卡 & 宕机问题总结

- 安装驱动后，提示输入`nvidia-smi`提示`no devices were found`
    - 系统为BIOS引导，改为UEFI并且关闭安全引导
    - 查看系统引导方式：`[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS`
- 虚拟机系统
    - A40显卡，高版本驱动(535)，系统日志存在NVRM错误。解决方法：降低版本(470)
    - 容器内偶现掉卡问题。解决方法：禁用容器内的cgroups
    - 虚拟机系统kernel内出现`pci failed to assign`和`nvidia: module verification failed`，国软服务器同时也存在，忽略此问题
- RAID
    - RAID硬件缺失模块。解决方法：供应商补发
    - RAID驱动存在问题，原因在于此硬件太老，新的系统支持不好
        - 物理机为centos7无问题
        - 物理机改为ESXI 7系统后出现，运维指定特殊版本驱动解决
- 电源 & 散热问题
    - 整体服务器功率在电源限定范围内
    - 显卡突然高功率，供电疑似不足。供应商现场来查看日志，无解决方法
        - 虚拟机CPU、GPU全负荷压测下1天稳定运行。CPU保持60度，风扇全开。可稳定使用CPU、内存资源为原物理机的一半
    - 虚拟机CPU资源无限制，导致物理机宕机出现数据问题
        - 注意：不限制虚拟机用的CPU资源 + 物理机所使用的资源会导致宕机。原因：散热跟不上
        - 解决方法：重装物理机、虚拟机系统 & 限制虚拟机资源为物理机的一半
- GPU卡问题
    - 48训练机出现此问题，表现为：
        - 替换GPU前
            - 使用`llama_2_13b`模型，显存OOM，然后切换torch_dtype为torch.float16，正常运行几遍模型推理，机器就会出现死机问题
            - ESXI报错：`PCle Status Bus Uncorrectable Error Occured PClE
              Location:CPU1 PE1 PCIE1[#CPU1 PE1 P1 R3 SL1(Bus176-Dev2-Func0)]-Assert`
        - 替换GPU后
            - 今天上午开机后11:15，到下午15:51开机，kern、messages、syslog都没有发现系统的异常日志
            - GPU程序是在13:58:
              17停止的，原因是我在外部删除了依赖的数据库导致的。在另一台机器复现了这个过程，机器也没问题。所以GPU应该是在13:
              58:17之后，没有使用GPU的情况下死机的
    - 最终解决：更换主板、更新固件后，48无此问题

## kernel中出现 pci 问题

物理机ESXi 7 系统，虚拟机安装Debian 11 系统出现

[【openEuler-20.03-LTS-SP1-x86_64】4.19内核启动过程中打印no space for [io size 0x1000]错误](https://gitee.com/openeuler/kernel/issues/I3U7KL)

[有谁知道系统日志里面这个错是哪里出问题了？（我自己的问题）](https://github.com/coolsnowwolf/lede/issues/3752)

[dmesg: pci BAR 7: can't assign io](https://unix.stackexchange.com/questions/184098/dmesg-pci-bar-7-cant-assign-io)

国软231 重启服务器同样出现此问题，忽略

```
Nov 20 09:41:53 gpu-train kernel: [    0.666606] pci 0000:00:18.3: bridge window [io  0x1000-0x0fff] to [bus 1f] add_size 1000
Nov 20 09:41:53 gpu-train kernel: [    0.666607] pci 0000:00:18.4: bridge window [io  0x1000-0x0fff] to [bus 20] add_size 1000
Nov 20 09:41:53 gpu-train kernel: [    0.666608] pci 0000:00:18.5: bridge window [io  0x1000-0x0fff] to [bus 21] add_size 1000
Nov 20 09:41:53 gpu-train kernel: [    0.666609] pci 0000:00:18.6: bridge window [io  0x1000-0x0fff] to [bus 22] add_size 1000
Nov 20 09:41:53 gpu-train kernel: [    0.666610] pci 0000:00:18.7: bridge window [io  0x1000-0x0fff] to [bus 23] add_size 1000
Nov 20 09:41:53 gpu-train kernel: [    0.666625] pci 0000:00:16.0: BAR 15: assigned [mem 0x1ff002000000-0x1ff0021fffff 64bit pref]
Nov 20 09:41:53 gpu-train kernel: [    0.666627] pci 0000:00:0f.0: BAR 6: assigned [mem 0xfef00000-0xfef07fff pref]
Nov 20 09:41:53 gpu-train kernel: [    0.666629] pci 0000:00:10.0: BAR 6: assigned [mem 0xfef08000-0xfef0bfff pref]
Nov 20 09:41:53 gpu-train kernel: [    0.666630] pci 0000:00:15.0: BAR 13: assigned [io  0x4000-0x4fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666631] pci 0000:00:15.1: BAR 13: assigned [io  0x6000-0x6fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666632] pci 0000:00:15.2: BAR 13: assigned [io  0x7000-0x7fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666633] pci 0000:00:15.3: BAR 13: assigned [io  0x8000-0x8fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666634] pci 0000:00:15.4: BAR 13: assigned [io  0x9000-0x9fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666635] pci 0000:00:15.5: BAR 13: assigned [io  0xa000-0xafff]
Nov 20 09:41:53 gpu-train kernel: [    0.666636] pci 0000:00:15.6: BAR 13: assigned [io  0xb000-0xbfff]
Nov 20 09:41:53 gpu-train kernel: [    0.666637] pci 0000:00:15.7: BAR 13: assigned [io  0xc000-0xcfff]
Nov 20 09:41:53 gpu-train kernel: [    0.666638] pci 0000:00:16.1: BAR 13: assigned [io  0xd000-0xdfff]
Nov 20 09:41:53 gpu-train kernel: [    0.666639] pci 0000:00:16.2: BAR 13: assigned [io  0xe000-0xefff]
Nov 20 09:41:53 gpu-train kernel: [    0.666640] pci 0000:00:16.3: BAR 13: assigned [io  0xf000-0xffff]
Nov 20 09:41:53 gpu-train kernel: [    0.666642] pci 0000:00:16.4: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666643] pci 0000:00:16.4: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666645] pci 0000:00:16.5: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666645] pci 0000:00:16.5: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666647] pci 0000:00:16.6: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666648] pci 0000:00:16.6: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666649] pci 0000:00:16.7: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666650] pci 0000:00:16.7: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666651] pci 0000:00:17.0: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666652] pci 0000:00:17.0: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666653] pci 0000:00:17.1: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666654] pci 0000:00:17.1: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666655] pci 0000:00:17.2: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666656] pci 0000:00:17.2: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666658] pci 0000:00:17.3: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666658] pci 0000:00:17.3: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666660] pci 0000:00:17.4: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666660] pci 0000:00:17.4: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666662] pci 0000:00:17.5: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666663] pci 0000:00:17.5: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666664] pci 0000:00:17.6: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666664] pci 0000:00:17.6: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666666] pci 0000:00:17.7: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666666] pci 0000:00:17.7: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666668] pci 0000:00:18.0: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666668] pci 0000:00:18.0: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666670] pci 0000:00:18.1: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666670] pci 0000:00:18.1: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666672] pci 0000:00:18.2: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666672] pci 0000:00:18.2: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666674] pci 0000:00:18.3: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666674] pci 0000:00:18.3: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666676] pci 0000:00:18.4: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666677] pci 0000:00:18.4: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666678] pci 0000:00:18.5: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666679] pci 0000:00:18.5: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666680] pci 0000:00:18.6: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666681] pci 0000:00:18.6: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666682] pci 0000:00:18.7: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666683] pci 0000:00:18.7: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666687] pci 0000:00:18.7: BAR 13: assigned [io  0x4000-0x4fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666688] pci 0000:00:18.6: BAR 13: assigned [io  0x6000-0x6fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666689] pci 0000:00:18.5: BAR 13: assigned [io  0x7000-0x7fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666690] pci 0000:00:18.4: BAR 13: assigned [io  0x8000-0x8fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666691] pci 0000:00:18.3: BAR 13: assigned [io  0x9000-0x9fff]
Nov 20 09:41:53 gpu-train kernel: [    0.666693] pci 0000:00:18.2: BAR 13: assigned [io  0xa000-0xafff]
Nov 20 09:41:53 gpu-train kernel: [    0.666694] pci 0000:00:18.1: BAR 13: assigned [io  0xb000-0xbfff]
Nov 20 09:41:53 gpu-train kernel: [    0.666695] pci 0000:00:18.0: BAR 13: assigned [io  0xc000-0xcfff]
Nov 20 09:41:53 gpu-train kernel: [    0.666696] pci 0000:00:17.7: BAR 13: assigned [io  0xd000-0xdfff]
Nov 20 09:41:53 gpu-train kernel: [    0.666697] pci 0000:00:17.6: BAR 13: assigned [io  0xe000-0xefff]
Nov 20 09:41:53 gpu-train kernel: [    0.666698] pci 0000:00:17.5: BAR 13: assigned [io  0xf000-0xffff]
Nov 20 09:41:53 gpu-train kernel: [    0.666699] pci 0000:00:17.4: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666700] pci 0000:00:17.4: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666701] pci 0000:00:17.3: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666702] pci 0000:00:17.3: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666703] pci 0000:00:17.2: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666704] pci 0000:00:17.2: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666705] pci 0000:00:17.1: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666706] pci 0000:00:17.1: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666707] pci 0000:00:17.0: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666708] pci 0000:00:17.0: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666709] pci 0000:00:16.7: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666710] pci 0000:00:16.7: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666711] pci 0000:00:16.6: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666712] pci 0000:00:16.6: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666713] pci 0000:00:16.5: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666714] pci 0000:00:16.5: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666715] pci 0000:00:16.4: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666716] pci 0000:00:16.4: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666717] pci 0000:00:16.3: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666718] pci 0000:00:16.3: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666719] pci 0000:00:16.2: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666720] pci 0000:00:16.2: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666721] pci 0000:00:16.1: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666722] pci 0000:00:16.1: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666723] pci 0000:00:15.7: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666724] pci 0000:00:15.7: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666725] pci 0000:00:15.6: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666726] pci 0000:00:15.6: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666727] pci 0000:00:15.5: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666728] pci 0000:00:15.5: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666729] pci 0000:00:15.4: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666730] pci 0000:00:15.4: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666731] pci 0000:00:15.3: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666732] pci 0000:00:15.3: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666733] pci 0000:00:15.2: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666734] pci 0000:00:15.2: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666735] pci 0000:00:15.1: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666736] pci 0000:00:15.1: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666737] pci 0000:00:15.0: BAR 13: no space for [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666738] pci 0000:00:15.0: BAR 13: failed to assign [io  size 0x1000]
Nov 20 09:41:53 gpu-train kernel: [    0.666740] pci 0000:00:01.0: PCI bridge to [bus 01]
Nov 20 09:41:53 gpu-train kernel: [    0.666837] pci 0000:02:00.0: BAR 6: assigned [mem 0xf9800000-0xf980ffff pref]
Nov 20 09:41:53 gpu-train kernel: [    0.666838] pci 0000:00:11.0: PCI bridge to [bus 02]
```

国软231启动后

```
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.4: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.5: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.6: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.7: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.0: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.1: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.2: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.3: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.4: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.5: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.6: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.7: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.0: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.1: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.2: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.3: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.4: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.5: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.6: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:18.7: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.5: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.4: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.3: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.2: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.1: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:17.0: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.7: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.6: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.5: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.4: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.3: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.2: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:16.0: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.7: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.6: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.5: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.4: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.3: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.2: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:30 gpu-231 kernel: pci 0000:00:15.1: BAR 13: failed to assign [io  size 0x1000]
Nov 21 10:15:32 gpu-231 kernel: nvidia: module verification failed: signature and/or required key missing - tainting kernel
```



