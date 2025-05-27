FROM ubuntu:20.04

EXPOSE 22
USER root

ARG WORKSPACE_DIR=/workspace

ARG HOME_DIR=/root
ARG APP_DIR=${HOME_DIR}/app
ARG DESKTOP_DIR=${HOME_DIR}/Desktop

ARG GITHUB_MIRROR='hub.fastgit.xyz'
ENV DESKTOP_DIR=${DESKTOP_DIR}
ENV SSH_PASSWORD=ewell123

ARG OH_MY_ZSH_DIR=${HOME_DIR}/.oh-my-zsh
ARG ZSH_CUSTOM_DIR=${OH_MY_ZSH_DIR}/custom
ARG ZSHRC_PATH=${HOME_DIR}/.zshrc

# 镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC

# 基础工具
ENV TZ=Asia/Shanghai
RUN apt-get clean && apt-get update -y && apt-get upgrade -y  \
    && apt-get install coreutils vim unzip wget curl telnet iputils-ping net-tools -y \
    && apt-get install locales -y && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 && locale -a && locale \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get install tzdata && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
ENV LC_ALL=zh_CN.UTF-8

# SSH [用Dockerfile配置SSH远端登陆ubuntu](https://www.jianshu.com/p/a97faf8b6da1)
RUN apt-get clean && apt-get update \
    && apt-get install -y openssh-server \
    && mkdir -p /var/run/sshd && mkdir -p ${HOME_DIR}/.ssh \
    && sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config \
    && sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config \
    && sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
WORKDIR ${DESKTOP_DIR}
RUN echo 'echo "root:${SSH_PASSWORD}" | chpasswd' >> run.sh \
    && echo '/usr/sbin/sshd -D' >> run.sh \
    && chmod 755 run.sh

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
    && cat zsh_profile >> ${ZSHRC_PATH} && rm -rf zsh_profile

# CMake
WORKDIR /tmp
RUN wget "https://${GITHUB_MIRROR}/Kitware/CMake/releases/download/v3.21.6/cmake-3.21.6-linux-x86_64.tar.gz" \
    && tar -zxvf cmake-3.21.6-linux-x86_64.tar.gz && mv cmake-3.21.6-linux-x86_64 /opt/cmake-3.21.6 \
    && ln -sf /opt/cmake-3.21.6/bin/*  /usr/bin/ \
    && cmake --version \
    && rm -rf /tmp
RUN apt-get clean && apt-get update \
    && apt-get install -y make gcc g++ gdb rsync \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log


WORKDIR ${WORKSPACE_DIR}
CMD ["sh", "-c", "${DESKTOP_DIR}/run.sh"]