ARG PULL_CUDA_VERSION
FROM ${PULL_CUDA_VERSION}

USER root

ENV HOME_DIR=/root
ENV APP_DIR=/opt/app
ENV DEPLOY_DIR=${APP_DIR}/deploy

WORKDIR ${APP_DIR}/

# 1. 基础系统环境。不建议进行改动
COPY ./shell_build/install_system.sh ./
RUN chmod +x ./install_system.sh && ./install_system.sh && rm -rf ./install_system.sh
# 防止docker exec -it name zsh后出现错误：command not found: print_icon。原因是执行locale，显示值错误
ENV LC_ALL=zh_CN.UTF-8

# 2. MiniForge安装。不建议进行改动
ENV MINIFORGE_DIR=${APP_DIR}/miniforge
ENV PATH="${MINIFORGE_DIR}/bin:$PATH"
COPY ./shell_build/install_miniforge.sh ./
RUN chmod +x ./install_miniforge.sh && ./install_miniforge.sh && rm -rf ./install_miniforge.sh
