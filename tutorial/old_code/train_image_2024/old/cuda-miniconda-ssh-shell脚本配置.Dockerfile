ARG FROM_VERSION
FROM alg:${FROM_VERSION}

EXPOSE 22
USER root

ENV WORKSPACE_DIR=/workspace

WORKDIR ${WORKSPACE_DIR}

# 1. SSH
ENV SSH_PASSWORD=ewell123
COPY ./base/install_ssh.sh ./
RUN chmod +x ./install_ssh.sh && ./install_ssh.sh && rm -rf ./install_ssh.sh

# 2. Supervisor
ENV CONFIG_DIR=/opt/config
COPY config ${CONFIG_DIR}
COPY ./base/install_supervisor.sh ./
RUN chmod +x ./install_supervisor.sh && ./install_supervisor.sh && rm -rf ./install_supervisor.sh


WORKDIR ${WORKSPACE_DIR}
ENTRYPOINT ["/usr/bin/supervisord", "-n"]
