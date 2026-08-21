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

# 修改密码
declare -A accounts=(
  ["root"]="/run/secrets/root_password"
  ["${USER_NAME}"]="/run/secrets/user_password"
)

for account in "${!accounts[@]}"; do
  pwd_file="${accounts[$account]}"
  if [ -f "$pwd_file" ]; then
    pwd=$(cat "$pwd_file")
    echo "修改 ${account} 密码成功，密码值位于：${pwd_file}"
    echo "${account}:${pwd}" | chpasswd
  else
    echo "${pwd_file} 不存在，不修改 ${account} 密码"
  fi
done

echo "【用户组】"
groups root "${USER_NAME}"
