#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Check for 'curl' command existence
if ! command_exists curl; then
    exit_with_error "Error: 'curl' is required to download files."
fi

# Install kubectl
install_kubectl() {
    echo_with_color "$GREEN_COLOR" "Downloading kubectl binary for macOS..."
    if curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/darwin/arm64/kubectl"; then
        chmod +x kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        sudo chown root: /usr/local/bin/kubectl
        echo_with_color "$GREEN_COLOR" "kubectl installed successfully"
    else
        exit_with_error "Failed to download kubectl."
    fi
}

# Install kubectl-krew
install_kubectl_krew() {
    echo_with_color "$GREEN_COLOR" "Downloading kubectl-krew for macOS..."
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir" &&
        OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
        KREW="krew-${OS}_${ARCH}" &&
        if curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"; then
            tar zxvf "${KREW}.tar.gz" &&
                ./"${KREW}" install krew
            echo_with_color "$GREEN_COLOR" "kubectl-krew installed successfully"
        else
            exit_with_error "Failed to download or install kubectl-krew."
        fi
}

# Check if kubectl is installed
if ! command_exists kubectl; then
    install_kubectl
else
    echo_with_color "$YELLOW_COLOR" "kubectl is already installed on macOS."
fi

# Check if kubectl krew is installed
if ! kubectl krew &>/dev/null; then
    install_kubectl_krew
else
    echo_with_color "$YELLOW_COLOR" "kubectl krew is already installed on macOS."
fi
