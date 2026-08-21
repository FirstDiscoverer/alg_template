
USER root

# 3. 需要root安装的软件
RUN --mount="type=bind,source=build_script/root/install_tool.sh,target=install_tool.sh" \
    bash install_tool.sh

# 4. 普通用户
USER ${USER_NAME}

# 4.1 linuxbrew
RUN --mount="type=bind,source=build_script/no_root/brew_install.sh,target=brew_install.sh" \
    --mount="type=bind,source=build_script/no_root/brew_config.sh,target=brew_config.sh" \
     bash -c 'bash brew_install.sh && bash brew_config.sh'