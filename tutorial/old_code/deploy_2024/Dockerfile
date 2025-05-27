FROM ubuntu:22.04

USER root

ENV HOME_DIR=/root
ENV APP_DIR=/opt/app
ENV DEPLOY_DIR=${APP_DIR}/deploy

WORKDIR ${APP_DIR}/

# 1. 基础系统环境。不建议进行改动
COPY ./deploy/shell_build/install_system.sh ./
RUN chmod +x ./install_system.sh && ./install_system.sh && rm -rf ./install_system.sh
ENV LC_ALL=zh_CN.UTF-8

# 2. MiniForge安装。不建议进行改动
ENV MINIFORGE_DIR=${APP_DIR}/miniforge
ENV PATH ${MINIFORGE_DIR}/bin:$PATH
COPY ./deploy/shell_build/install_miniforge.sh ./
RUN chmod +x ./install_miniforge.sh && ./install_miniforge.sh && rm -rf ./install_miniforge.sh

# 3. 项目运行环境
# [Activate conda environment in docker](https://stackoverflow.com/questions/55123637/activate-conda-environment-in-docker)、[Conda Docker tutoria](https://kevalnagda.github.io/conda-docker-tutorial)
# ① 自定义项目的Python版本
ARG PYTHON_VERSION=3.10
ENV DEPLOY_ENV=app_env
RUN conda create -y -n ${DEPLOY_ENV} python=${PYTHON_VERSION} && conda clean --all --yes --verbose \
    && echo 'conda activate ${DEPLOY_ENV}' >> ${HOME_DIR}/.bashrc
# SHELL[]的作用时是在后面的RUN执行时先激活conda环境；--no-capture-output是为了不捕获后面shell的日志输出
SHELL ["conda", "run", "--no-capture-output", "-n", "app_env", "/bin/bash", "-c"]

# 健康检测
# ② 保证web服务有/ok接口
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD curl --silent --fail http://127.0.0.1:8080/ok || exit 1

# 依赖单独构建
WORKDIR ${DEPLOY_DIR}/
# ③ 项目系统环境初始化
COPY ./deploy/init.sh ./
RUN chmod +x ./init.sh && ./init.sh && rm -rf ./init.sh
COPY ./requirements.txt ./
RUN pip install -r requirements.txt --retries=3 --timeout=30 --no-cache-dir

# 复制代码
ENV PYTHONPATH "${DEPLOY_DIR}"
COPY . ./
# ④ 项目的启动初始化
RUN chmod a+x ${DEPLOY_DIR}/deploy/start.sh

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "app_env", "./deploy/start.sh"]