FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]
USER root

# 1. 基础系统环境。不建议进行改动
RUN --mount="type=bind,source=deploy/build_script/root/install_system.sh,target=run.sh" \
    bash run.sh
# 防止shell使用zsh时，docker exec -it name zsh后出现错误：command not found: print_icon。原因是执行locale，显示值错误
ENV LC_ALL=zh_CN.UTF-8

# 2. 新增用户。不建议进行改动
ARG USER_NAME=appuser
ENV USER_NAME=${USER_NAME}
RUN useradd --create-home --shell /bin/bash "${USER_NAME}" && groups root "${USER_NAME}"

USER ${USER_NAME}
# 3. MiniConda。不建议进行改动
RUN --mount="type=bind,source=deploy/build_script/nonroot/install_miniforge.sh,target=run.sh" \
    bash run.sh
# 其他用户也会生效conda，但是容器内部不使用其他用户，问题不大
ENV PATH="/home/${USER_NAME}/Software/miniforge/bin:${PATH}"

# 4. 项目运行环境
# [Activate conda environment in docker](https://stackoverflow.com/questions/55123637/activate-conda-environment-in-docker)、[Conda Docker tutoria](https://kevalnagda.github.io/conda-docker-tutorial)
# ① 自定义项目的Python版本
ARG PYTHON_VERSION="3.10"
ARG APP_DEPLOY_ENV="my_app"
RUN conda create -y -n ${APP_DEPLOY_ENV} python=${PYTHON_VERSION} && conda clean --all --yes --verbose \
    && echo "conda activate ${APP_DEPLOY_ENV}" >> "/home/${USER_NAME}/.bashrc"

# SHELL[]的作用时是在后面的RUN执行时先激活conda环境；--no-capture-output是为了不捕获后面shell的日志输出
SHELL ["conda", "run", "--no-capture-output", "-n", "my_app", "/bin/bash", "-c"]

# 健康检测
# ② 保证web服务有/ok接口
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD curl --silent --fail http://127.0.0.1:8080/ok || exit 1

# 依赖单独构建
ENV DEPLOY_DIR="/home/${USER_NAME}/deploy_code"
WORKDIR ${DEPLOY_DIR}/
# ③ 项目系统环境初始化
USER root
RUN --mount="type=bind,source=deploy/init_root.sh,target=run.sh" \
    bash run.sh

USER ${USER_NAME}
RUN --mount="type=bind,source=deploy/init_nonroot.sh,target=run.sh" \
    bash run.sh
RUN --mount="type=bind,source=requirements.txt,target=requirements.txt" \
    which pip && pip install -r requirements.txt --retries=3 --timeout=30 --no-cache-dir

# 复制代码
ENV PYTHONPATH "${DEPLOY_DIR}"
COPY --chown="${USER_NAME}:${USER_NAME}" . .
# ④ 项目的启动初始化
RUN chmod +x deploy/start.sh

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "my_app", "deploy/start.sh"]