#!/bin/bash

# 1. 镜像源
cp /etc/apt/sources.list /etc/apt/sources.list.bakup
sed -i 's/archive.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list

cd /etc/apt/sources.list.d || exit
# 去除CUDA镜像源避免后续apt更新
for file in *; do
  # 判断是否是文件，并且文件名符合条件：cuda-开头、不是.backup结尾
  if [[ -f "$file" && "$file" == cuda-* && "$file" != *.backup ]]; then
    mv "$file" "$file.backup"
    echo "重命名: $file -> $file.backup"
  fi
done

# 2. dist-upgrade
apt-get clean && apt-get update -y -q
# 静默升级，防止打断。--force-confdef：让 dpkg 自动使用默认处理方式，而不再反复询问。--force-confold：在发现当前系统的配置文件与新版本冲突时，自动保留你当前的“旧”配置文件。
DEBIAN_FRONTEND=noninteractive \
     apt-get dist-upgrade -y -q \
     -o Dpkg::Options::="--force-confdef" \
     -o Dpkg::Options::="--force-confold"

# 3. 常规软件安装
apt-get clean && apt-get update -y -qq && apt-get upgrade -y -qq

apt_get_install() {
  apt-get install -y --no-install-recommends -qq "$@"
}

# 防止wget出现证书错误：错误: 无法验证 mirrors.tuna.tsinghua.edu.cn 的由 ‘CN=R10,O=Let's Encrypt,C=US’ 颁发的证书
apt_get_install ca-certificates
update-ca-certificates

apt_get_install language-pack-zh-hans
apt_get_install locales && locale-gen zh_CN.UTF-8 && update-locale LANG=zh_CN.UTF-8 && locale
apt_get_install coreutils vim unzip wget curl telnet iputils-ping net-tools git

export TZ=Asia/Shanghai
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
apt_get_install tzdata && dpkg-reconfigure --frontend noninteractive tzdata

# Final: 清理垃圾
apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
