CONDA_BASE_BIN_DIR=$(dirname "${CONDA_EXE}")  # conda init后有这个变量
nvitop() {
    "${CONDA_BASE_BIN_DIR}/nvitop" "$@"
}
glances() {
    "${CONDA_BASE_BIN_DIR}/glances" "$@"
}
gpu_info() {
    watch -n1 --color "${CONDA_BASE_BIN_DIR}/gpustat -cpu --color"
}

alias grep="grep -i --color=auto"
alias l="ls -lF" 
alias ll="ls -alF" 

alias conda_clean='conda clean --all --yes --verbose'
alias pip_clean='pip cache purge'

alias log_supervisor='cd /var/log/supervisor'
alias log_screen='cd /var/log/screen'

fastfetch
