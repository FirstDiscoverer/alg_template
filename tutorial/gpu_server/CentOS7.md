# 升级内核

- [CentOS 7 内核升级最新记录(yum及编译) 2024-08](https://www.cnblogs.com/zhangwencheng/p/18252574)

```shell
# 系统信息
[root@localhost-01 ~]# cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)
[root@localhost-01 ~]# uname -r
3.10.0-862.el7.x86_64
 
# 更新yum仓库
# 如果只更新软件包可执行：yum -y update --exclude=kernel*
[root@localhost-01 ~]# yum -y update
 
 
# 当前内核信息
[root@localhost-01 ~]# rpm -qa | grep kernel
kernel-3.10.0-1160.119.1.el7.x86_64
kernel-tools-libs-3.10.0-1160.119.1.el7.x86_64
kernel-tools-3.10.0-1160.119.1.el7.x86_64
kernel-3.10.0-862.el7.x86_64
 
# 由于ELRepo仓库的不再支持 CentOS 7 ,只能手动下载需要版本rpm包，这里选择安装版本（kernel-lt-5.4.278）
[root@localhost-01 ~]# wget https://mirrors.aliyun.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm
[root@localhost-01 ~]# wget https://mirrors.aliyun.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm
[root@localhost-01 ~]# wget https://mirrors.aliyun.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-lt-headers-5.4.278-1.el7.elrepo.x86_64.rpm
[root@localhost-01 ~]# wget https://mirrors.aliyun.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-lt-tools-5.4.278-1.el7.elrepo.x86_64.rpm
[root@localhost-01 ~]# wget https://mirrors.aliyun.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-lt-tools-libs-5.4.278-1.el7.elrepo.x86_64.rpm
[root@localhost-01 ~]# wget https://mirrors.aliyun.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-lt-doc-5.4.278-1.el7.elrepo.noarch.rpm
 
[root@localhost-01 ~]# yum localinstall kernel-lt-*
 
# 若安装提示冲突，则卸载旧版本tools
[root@localhost-01 ~]# yum remove kernel-tools-libs-3.10.0-1160.119.1.el7.x86_64 kernel-tools-3.10.0-1160.119.1.el7.x86_64
 
# 查看当前默认内核启动
[root@localhost-01 ~]# grub2-editenv list
saved_entry=CentOS Linux (3.10.0-1160.119.1.el7.x86_64) 7 (Core)
 
# 查看当前内核启动可选项
[root@localhost-01 ~]# awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (5.4.278-1.el7.elrepo.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-1160.119.1.el7.x86_64) 7 (Core)
2 : CentOS Linux (3.10.0-862.el7.x86_64) 7 (Core)
3 : CentOS Linux (0-rescue-c4ad8cdbfdb44ce190f1c662815d35f4) 7 (Core)
 
# 修改默认启动顺序
[root@localhost-01 ~]# ls -l /etc/grub2.cfg
lrwxrwxrwx 1 root root 22 Jun 17 15:23 /etc/grub2.cfg -> ../boot/grub2/grub.cfg
 
[root@localhost-01 ~]# grub2-set-default 'CentOS Linux (5.4.278-1.el7.elrepo.x86_64) 7 (Core)'
[root@localhost-01 ~]# grub2-editenv list
saved_entry=CentOS Linux (5.4.278-1.el7.elrepo.x86_64) 7 (Core)
 或
[root@localhost-01 ~]# grub2-set-default 0
[root@localhost-01 ~]# grub2-editenv list
saved_entry=0
 
# 重启生效
[root@localhost-01 ~]# reboot
 
# 验证结果
[root@localhost-01 ~]# cat /etc/redhat-release
CentOS Linux release 7.9.2009 (Core)
[root@localhost-01 ~]# uname -r
5.4.278-1.el7.elrepo.x86_64
```

# 卸载Docker

- [CentOS 7 彻底卸载 Docker 环境](https://juejin.cn/post/7307857550724005926)
    - Warning：先升级内核再安装docker，防止升级后docker的东西丢失

```shell
# 步骤一：杀死所有运行中的容器 
docker kill $(docker ps -a -q)

# 步骤二：删除所有 Docker 容器
docker rmi $(docker images -q)

# 清理所有数据
docker system prune -all

# 步骤四：停止 Docker 服务
sudo systemctl stop docker.socket
sudo systemctl stop docker.service

# 步骤五：删除存储目录
sudo rm -rf /etc/docker
sudo rm -rf /run/docker
sudo rm -rf /var/lib/dockershim
sudo rm -rf /var/lib/docker

# 注意事项
# 如果遇到无法删除的目录，可能需要先解除挂载。例如：
umount /var/lib/docker/devicemapper

# 步骤六：卸载 Docker
# 查看已安装的 Docker 包
sudo yum list installed | grep docker
# 卸载相关包
sudo yum remove -y 'docker*'
sudo yum remove -y containerd.io.x86_64
```

