export PATH="${HOME}/.local/bin:${PATH}"

# conda init后有这个变量
CONDA_ROOT_DIR=$(dirname $(dirname "${CONDA_EXE}"))

export PIPX_HOME="${HOME}/Software/pipx"
export PIPX_DEFAULT_BACKEND="uv"
export PIPX_MAX_LOGS=50
CONDA_PIPX_HOME="${CONDA_ROOT_DIR}/envs/base-pipx"
export PIPX_DEFAULT_PYTHON="${CONDA_PIPX_HOME}/bin/python"

gpu_info() {
    watch -n1 --color "gpustat -cpu --color"
}

alias grep="grep -i --color=auto"
alias l="ls -lF" 
alias ll="ls -alF" 

alias conda_clean='conda clean --all --yes --verbose'
alias mamba_clean='mamba clean --all --yes --verbose'
alias pip_clean='pip cache purge'
alias pipx_clean='pipx cache purge'
alias uv_clean='uv cache clean'

alias log_supervisor='cd /var/log/supervisor'
alias log_screen='cd /var/log/screen'
