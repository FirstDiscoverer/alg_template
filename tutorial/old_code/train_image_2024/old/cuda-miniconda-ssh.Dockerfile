ARG FROM_VERSION
FROM alg:${FROM_VERSION}

EXPOSE 22
USER root

ARG WORKSPACE_DIR=/workspace
ENV SSH_PASSWORD=ewell123


# SSH [用Dockerfile配置SSH远端登陆ubuntu](https://www.jianshu.com/p/a97faf8b6da1)
RUN apt-get clean && apt-get update \
    && apt-get install -y openssh-server \
    && mkdir -p /var/run/sshd && mkdir -p ${HOME_DIR}/.ssh \
    && sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config \
    && sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config \
    && sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log

# Supervisor
# [Run multiple services in a container](https://docs.docker.com/config/containers/multi-service_container/)
# [UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations](https://stackoverflow.com/questions/63608075/userwarning-supervisord-is-running-as-root-and-it-is-searching-for-its-configur)
RUN apt-get clean && apt-get update -y && apt-get upgrade -y  \
    && apt-get install -y supervisor \
    && apt-get autoremove &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log \
    && mkdir -p /var/log/supervisor \
    && echo "user=root" >> /etc/supervisor/supervisord.conf
ARG CONFIG_DIR=/opt/config

COPY config ${CONFIG_DIR}
RUN ln -s ${CONFIG_DIR}/supervisor/*.conf /etc/supervisor/conf.d/  \
    && ls -l /etc/supervisor/conf.d/  \
    && chmod 755 ${CONFIG_DIR}/supervisor/*.sh

WORKDIR ${WORKSPACE_DIR}
ENTRYPOINT ["/usr/bin/supervisord", "-n"]
