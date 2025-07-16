# .bashrc
source ~/my_helpers/bash/bash_functions.sh
source ~/my_helpers/bash/kubectl_functions.sh

#No PS1 installed
if [[ ! -f ~/.bash_config/.kube-ps1.sh ]]; then
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\e[34m\]\h\[\e[m\]:\033[33;1m\]\w\[\033[m\] $ "
else
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\e[34m\]\h\[\e[m\]\$(kube_ps1):\033[33;1m\]\w\[\033[m\] $ "
    #export PS1="\[\033[38;5;27m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;245m\]$config_environment\[$(tput sgr0)\]$(kube_ps1): \[$(tput sgr0)\]\[\033[38;5;160m\]\w\[$(tput sgr0)\] \\$ \[$(tput sgr0)\]"
fi