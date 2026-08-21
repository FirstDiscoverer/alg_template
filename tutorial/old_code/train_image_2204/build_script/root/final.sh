#!/bin/bash

variables=("USER_NAME")
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

# 1. 保存镜像的环境变量到文件。解决在用户在ssh登陆后LC_ALL等环境变量缺失
export DOCKER_ENV_PATH=/etc/zsh/my_docker.env
# HOME必须排除了，否则会污染非ROOT用户；PWD也必须排除，否则oh-my-zsh在ssh登陆后显示的目录为这个变量值
tr '\0' '\n' < /proc/1/environ | grep -Ev '^(HOME|PWD|HOSTNAME)' > ${DOCKER_ENV_PATH}
cp /etc/zsh/zshenv /etc/zsh/zshenv.backup
echo >> /etc/zsh/zshenv

cat << EOF >> /etc/zsh/zshenv
if [ -f ${DOCKER_ENV_PATH} ]; then
    # source ${DOCKER_ENV_PATH} # 部分变量无法设置，不实用这种方法

    # IFS= 防止默认的分隔符导致行内容被拆分
    # -r 参数防止反斜杠被解释
    # "|| [ -n "\${line}" ]" 用于确保文件最后一行没有换行符时也能被读取
    while IFS= read -r line || [ -n "\${line}" ]; do
      # 判断当前行是否非空并且不以 '#' 开头（排除注释行）
      if [[ -n "\${line}" && "\${line}" != \#* ]]; then
        # 执行 export 命令，将当前行内容设置为环境变量
        # 此处假设每行内容的格式均为 VAR=VALUE
        export "\${line}"
      fi
    done < "${DOCKER_ENV_PATH}"
else
    echo "Warning：${DOCKER_ENV_PATH} 文件不存在，请检查！"
fi
EOF

# 2. 最后给当前用户授权sudo。避免在前面给，防止在构建镜像的时候普通用户用sudo权限
usermod -aG sudo "${USER_NAME}"
