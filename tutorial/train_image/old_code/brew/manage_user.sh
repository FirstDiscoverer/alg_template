#!/bin/bash

# 3. 普通账户：linuxbrew
useradd --create-home --shell /bin/bash linuxbrew
usermod -aG linuxbrew ${USER_NAME}

HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
mkdir ${HOMEBREW_PREFIX}
chown -R linuxbrew: ${HOMEBREW_PREFIX}
chmod -R 775 ${HOMEBREW_PREFIX}
ls -al /home/linuxbrew

groups root ${USER_NAME} linuxbrew