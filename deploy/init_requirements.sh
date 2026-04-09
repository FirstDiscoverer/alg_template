#!/bin/bash

which pip pip3 python python3

REQ_PATH=/tmp/requirements.txt
RETRIES=3
TIMEOUT=30


echo "是否使用UV: ${ENABLE_UV}"
if [ "${ENABLE_UV}" != "false" ]; then
  pip install uv

  if [ "${ENABLE_CHINA_MIRROR}" != "false" ]; then
    echo "UV切换到国内源..."
    mkdir -p "${HOME}/.config/uv"
    cat > "${HOME}/.config/uv/uv.toml" << EOF
[pip]
index-url = "https://mirrors.aliyun.com/pypi/simple"
extra-index-url = [
    "https://mirrors.aliyun.com/pypi/simple",
    "https://mirrors.cloud.tencent.com/pypi/simple",
    "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple",
    "https://mirrors.bfsu.edu.cn/pypi/web/simple"
]
EOF
  fi

  UV_HTTP_RETRIES=${RETRIES}
  UV_HTTP_TIMEOUT=${TIMEOUT}

  uv pip install -r ${REQ_PATH}

  uv cache clean
  uv cache prune
else
  pip install -r ${REQ_PATH} --retries=${RETRIES} --timeout=${TIMEOUT}
fi

pip cache purge
