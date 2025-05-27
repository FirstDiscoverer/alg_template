ARG FROM_VERSION
FROM alg:${FROM_VERSION}

EXPOSE 22
USER root

ENV GITHUB_MIRROR='https://githubfast.com'
ENV GITHUB_DOWN_MIRROR='https://www.ghproxy.cc/https://github.com'
ENV WORKSPACE_DIR=/workspace

# 1. SSH
WORKDIR ${WORKSPACE_DIR}
ENV SSH_PASSWORD=ewell123
COPY ./shell_build/install_ssh.sh ./
RUN chmod +x ./install_ssh.sh && ./install_ssh.sh && rm -rf ./install_ssh.sh

# 2. Supervisor
# Supervisor①: 安装
ENV CONFIG_DIR=/opt/config
COPY config ${CONFIG_DIR}
COPY ./shell_build/install_supervisor.sh ./
RUN chmod +x ./install_supervisor.sh && ./install_supervisor.sh && rm -rf ./install_supervisor.sh

# 3. ZSH
WORKDIR ${HOME_DIR}
COPY ./config_build/zsh_theme .
COPY ./config_build/zsh_profile .
COPY ./shell_build/install_zsh.sh .
RUN chmod +x ./install_zsh.sh && ./install_zsh.sh && rm -rf ./install_zsh.sh

# ################################ ZSH的问题 start ################################
#【Python3.6 open中文文件错误 or logging中文错误】
# [解决UnicodeEncodeError。python的docker镜像增加locale 中文支持](https://www.cnblogs.com/xuanmanstein/p/9100507.html)
# [docker 中 UnicodeEncodeError: ‘ascii‘ codec can‘t encode characters in position 30-37](https://blog.csdn.net/liuskyter/article/details/114589442)
# ENV LC_ALL=zh_CN.UTF-8    # 已在上个依赖的dockerfile设置

## 【Pycharm使用ssh调试代码缺失环境变量缺失LC_ALL】
# [pycharm ssh远程解释器连接docker容器环境变量缺失](https://blog.csdn.net/Farm_Coder/article/details/122212169)
COPY ./config_build/zshenv .
RUN cat ./zshenv >> /etc/zsh/zshenv && rm -rf ./zshenv
# ################################ ZSH的问题 end ################################

# 4. 常用工具
COPY ./shell_build/install_tool.sh .
RUN chmod +x ./install_tool.sh && ./install_tool.sh && rm -rf ./install_tool.sh

# final: 检查工具安装
COPY ./shell_build/check.sh .
RUN chmod +x ./check.sh && ./check.sh && rm -rf ./check.sh

# Supervisor②: 启动
WORKDIR ${WORKSPACE_DIR}
ENTRYPOINT ["/usr/bin/supervisord", "-n"]