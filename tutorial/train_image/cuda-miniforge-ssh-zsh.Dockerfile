ARG ORIGINAL_IMAGE
FROM ${ORIGINAL_IMAGE}

USER root

# 0. 账户管理
RUN --mount="type=secret,id=root_password" \
    --mount="type=secret,id=user_password" \
    --mount="type=bind,source=build_config/root/supervisor/conf.d/user_chpasswd.sh,target=run.sh" \
    bash run.sh

# 1. root安装工具
COPY build_config/root/supervisor /etc/supervisor
RUN --mount="type=bind,source=build_script/root/install_tool.sh,target=run.sh" \
    bash run.sh

# 2. 用户级别工具
USER ${USER_NAME}
RUN --mount="type=bind,source=build_script/nonroot/config_tool.sh,target=run.sh" \
    --mount="type=bind,source=build_config/nonroot/zsh,target=/config_my/zsh_config" \
    bash run.sh

# 3. root的最后配置
USER root
RUN --mount="type=bind,source=build_script/root/final.sh,target=run.sh" \
    bash run.sh

ENTRYPOINT ["/usr/bin/supervisord", "-n"]