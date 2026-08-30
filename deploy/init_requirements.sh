#!/bin/bash

which pip pip3 python python3

REQ_PATH=/tmp/requirements.txt
RETRIES=3
TIMEOUT=30


echo "是否使用UV: ${ENABLE_UV}"
if [ "${ENABLE_UV}" != "false" ]; then
  pip install uv

  export UV_HTTP_RETRIES=${RETRIES} UV_HTTP_TIMEOUT=${TIMEOUT}
  uv pip install -r ${REQ_PATH}

  uv cache clean
else
  pip install -r ${REQ_PATH} --retries=${RETRIES} --timeout=${TIMEOUT}
fi

pip cache purge
