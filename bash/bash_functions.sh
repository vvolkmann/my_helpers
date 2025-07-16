#!/bin/bash

# Vars definitions
# Krew Plugin list: https://krew.sigs.k8s.io/plugins/
krew_plugin_list="
    df-pv
    ns
    unused-volumes
    view-cert
	view-secret
	view-utilization
"
krew_plugin_list_full="
	deprecations
	df-pv
	doctor
	get-all
	janitor
	ns
	pod-dive
	pod-inspect
	podevents
	prune-unused
	reap
	resource-capacity
	sick-pods
	status
	unused-volumes
	view-cert
	view-secret
	view-utilization
"

function install_kubectl() {
	# Check if kubectl is installed
	if [[ ! -f /usr/local/bin/kubectl ]]; then
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		rm kubectl
		
        bash_info=$(cat ~/.bashrc)
		if [[ $bash_info != *"kubectl completion"* ]]; then
            echo 'source <(kubectl completion bash)' >> ~/.bashrc
            echo 'complete -F __start_kubectl k' >> ~/.bashrc
            #kubectl completion bash >/etc/bash_completion.d/kubectl
        fi
		
		source ~/.bashrc
	fi
}
function install_krew() {
	# Add krew
	if [[ ! -d $HOME/.krew ]]; then
        (
			set -x; cd "$(mktemp -d)" &&
			OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
			ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
			KREW="krew-${OS}_${ARCH}" &&
			curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
			tar zxvf "${KREW}.tar.gz" &&
			./"${KREW}" install krew
		)

	fi
}


function install_krew_plugins() {
    # Install a few plugins
    for plugin in $krew_plugin_list ; do
        kubectl krew install "$plugin"
    done
}
function update_krew_plugins() {
	kubectl krew upgrade
    for plugin in $krew_plugin_list ; do
        kubectl krew update "$plugin"
    done
}

function download_ahmetb_kubectl_aliases() {
	# Add ahmetb aliases
	# Repo https://github.com/ahmetb/kubectl-aliases
	if [[ ! -f ~/.bash_config/.kubectl_aliases ]]; then
		curl -o ~/.bash_config/.kubectl_aliases -k https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases
		# Print the full command before running it
		echo 'function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }' >> ~/.bash_config/.kubectl_aliases
		
		source ~/.bash_config/.kubectl_aliases
	fi
}

function install_kubePS1_plugin() {
    if [[ ! -f ~/.bash_config/.kube-ps1.sh ]]; then
        curl -o ~/.bash_config/.kube-ps1.sh -k https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
        
    fi
}

function install_kustomize() {
	 if [[ ! -f ~/.bash_config/install_kustomize.sh ]]; then
        curl -o ~/.bash_config/install_kustomize.sh https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh
  		bash ~/.bash_config/install_kustomize.sh 4.2.0
        
		sudo cp kustomize /usr/local/bin/
		sudo chown root:root /usr/local/bin/kustomize
		sudo chmod 755 /usr/local/bin/kustomize
    fi
}

function load_kubePS1_config() {
	source ~/.bash_config/.kube-ps1.sh

	KUBE_PS1_CONTEXT_ENABLE=false
	KUBE_PS1_SYMBOL_ENABLE=false
	KUBE_PS1_PREFIX=[
	KUBE_PS1_SUFFIX=]
	KUBE_PS1_NS_COLOR=red
}

#Main function to load all configurations
function load_config() {
    if [[ ! -d ~/.bash_config ]]; then
        mkdir ~/.bash_config
        
        install_kubectl &> /dev/null
        install_krew &> /dev/null
        install_krew_plugins &> /dev/null
        
        install_kubePS1_plugin &> /dev/null
        download_ahmetb_kubectl_aliases &> /dev/null

		install_kustomize &> /dev/null
    fi

	export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

    #update_krew_plugins
    source ~/.bash_config/.kubectl_aliases
	load_kubePS1_config
}


# Extra aliases / functions
alias tf='terraform'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'

alias klogs10='kubectl logs --tail 10 -f'
alias klogs100='kubectl logs --tail 100 -f'


load_config