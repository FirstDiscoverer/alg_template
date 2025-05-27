ARG FROM_VERSION
FROM ew-alg:${FROM_VERSION}

EXPOSE 22
USER root

ARG WORKSPACE_DIR=/workspace
ARG HOME_DIR=/root
ARG GITHUB_MIRROR='gitclone.com/github.com'

ARG OH_MY_ZSH_DIR=${HOME_DIR}/.oh-my-zsh
ARG ZSH_CUSTOM_DIR=${OH_MY_ZSH_DIR}/custom
ARG ZSHRC_PATH=${HOME_DIR}/.zshrc

# ZSH美化
RUN apt-get clean && apt-get update \
    && apt-get install -y git && git config --global http.sslVerify false \
    && apt-get install -y zsh && chsh -s /bin/zsh \
    && apt-get install -y neofetch \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
RUN git clone https://${GITHUB_MIRROR}/ohmyzsh/ohmyzsh.git ${HOME_DIR}/.oh-my-zsh \
    && cp ${HOME_DIR}/.oh-my-zsh/templates/zshrc.zsh-template ${ZSHRC_PATH} \
    && git clone https://${GITHUB_MIRROR}/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions \
    && git clone https://${GITHUB_MIRROR}/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting \
    && git clone https://${GITHUB_MIRROR}/Powerlevel9k/powerlevel9k.git ${ZSH_CUSTOM_DIR}/themes/powerlevel9k
WORKDIR ${HOME_DIR}
COPY config_build/zsh_profile .
RUN sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ${ZSHRC_PATH} \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel9k\/powerlevel9k"/g' ${ZSHRC_PATH} \
    && cat zsh_profile >> ${ZSHRC_PATH} && rm -rf zsh_profile \
    && conda init zsh

# ################################ ZSH的问题 start ################################
#【Python3.6 open中文文件错误 or logging中文错误】
# [解决UnicodeEncodeError。python的docker镜像增加locale 中文支持](https://www.cnblogs.com/xuanmanstein/p/9100507.html)
# [docker 中 UnicodeEncodeError: ‘ascii‘ codec can‘t encode characters in position 30-37](https://blog.csdn.net/liuskyter/article/details/114589442)
ENV LC_ALL=zh_CN.UTF-8
## 【Pycharm使用ssh调试代码缺失环境变量缺失LC_ALL】
# [pycharm ssh远程解释器连接docker容器环境变量缺失](https://blog.csdn.net/Farm_Coder/article/details/122212169)
COPY config_build/zshenv .
RUN cat zshenv >> /etc/zsh/zshenv && rm -rf zshenv
# ################################ ZSH的问题 end ################################

# 常用工具
RUN apt-get clean && apt-get update \
    && apt-get install -y glances htop psmisc lsof rsync \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
RUN which pip3 && pip3 install nvitop gpustat --no-cache-dir

WORKDIR ${WORKSPACE_DIR}









