# conda init后有这个变量
CONDA_ROOT_DIR=$(dirname $(dirname "${CONDA_EXE}"))
CONDA_TOOL_BIN_DIR="${CONDA_ROOT_DIR}/envs/tool/bin"
nvitop() {
    "${CONDA_TOOL_BIN_DIR}/nvitop" "$@"
}
glances() {
    "${CONDA_TOOL_BIN_DIR}/glances" "$@"
}
gpu_info() {
    watch -n1 --color "${CONDA_TOOL_BIN_DIR}/gpustat -cpu --color"
}

alias grep="grep -i --color=auto"
alias l="ls -lF" 
alias ll="ls -alF" 

alias conda_clean='conda clean --all --yes --verbose'
alias mamba_clean='mamba clean --all --yes --verbose'
alias pip_clean='pip cache purge'
alias uv_clean='uv cache clean'

alias log_supervisor='cd /var/log/supervisor'
alias log_screen='cd /var/log/screen'
