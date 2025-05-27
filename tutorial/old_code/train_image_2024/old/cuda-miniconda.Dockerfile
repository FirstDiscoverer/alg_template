ARG PULL_CUDA_VERSION
FROM ${PULL_CUDA_VERSION}

USER root

ENV APP_DIR=/opt/app


# 镜像源
WORKDIR /etc/apt/sources.list.d
# 去除CUDA镜像源避免后续apt更新
RUN ls | grep 'cuda' | xargs -t -i sh -c "mv {} {}.bak"
WORKDIR ${APP_DIR}
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i 's/archive.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list

# 基础工具
ENV TZ=Asia/Shanghai
RUN apt-get clean && apt-get update -y && apt-get upgrade -y  \
    && apt-get install coreutils vim unzip wget curl telnet iputils-ping net-tools -y \
    && apt-get install locales -y && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 && locale -a && locale \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get install tzdata && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
ENV LC_ALL=zh_CN.UTF-8

# Conda
ARG CONDA_URL='https://mirrors.bfsu.edu.cn/anaconda/miniconda/Miniconda3-py310_23.9.0-0-Linux-x86_64.sh'
ENV CONDA_DIR=${APP_DIR}/miniconda
RUN wget ${CONDA_URL} -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp ${CONDA_DIR} && rm -rf /tmp/miniconda.sh \
    && export PATH=${CONDA_DIR}/bin:$PATH && conda init bash \
    && conda clean --all --yes
ENV PATH ${CONDA_DIR}/bin:$PATH

RUN conda config --set show_channel_urls yes \
    && conda config --append channels defaults \
    && conda config --add default_channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/main \
    && conda config --add default_channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/r \
    && conda config --add default_channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/msys2 \
    && conda config --set custom_channels.conda-forge https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda config --set custom_channels.msys2 https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda config --set custom_channels.bioconda https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda config --set custom_channels.menpo https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda config --set custom_channels.pytorch https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda config --set custom_channels.pytorch-lts https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda config --set custom_channels.simpleitk https://mirrors.bfsu.edu.cn/anaconda/cloud \
    && conda clean --all --yes --verbose && conda config --show-sources && conda config --validate \
    && conda info \
    && pip config set global.index-url https://mirrors.cloud.tencent.com/pypi/simple \
    && pip config set global.extra-index-url "https://mirrors.cloud.tencent.com/pypi/simple https://mirrors.aliyun.com/pypi/simple https://pypi.tuna.tsinghua.edu.cn/simple https://mirrors.bfsu.edu.cn/pypi/web/simple" \
    && pip config set global.no-cache-dir true

WORKDIR ${APP_DIR}












