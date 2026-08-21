ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-c"]
USER root

# 1. 基础系统环境。不建议进行改动
RUN --mount="type=bind,source=build_script/root/install_system.sh,target=run.sh" \
    bash run.sh
# 防止shell使用zsh时，docker exec -it name zsh后出现错误：command not found: print_icon。原因是执行locale，显示值错误
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

# 2. 新增用户。不建议进行改动
ARG USER_NAME=appuser
ENV USER_NAME=${USER_NAME}
ENV USER_ID=1001 GROUP_ID=1001

RUN groupadd -g ${GROUP_ID} "${USER_NAME}" \
    && useradd --create-home --no-log-init --shell /bin/bash -u ${USER_ID} -g ${GROUP_ID} "${USER_NAME}"

USER ${USER_NAME}
# 3. MiniConda。不建议进行改动
RUN --mount="type=bind,source=build_script/nonroot/install_miniforge.sh,target=run.sh" \
    bash run.sh
