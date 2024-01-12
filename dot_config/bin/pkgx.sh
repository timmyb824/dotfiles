#!/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

# Function to install pkgx
install_pkgx() {
    if command_exists brew; then
        echo_with_color "34" "Installing pkgx using Homebrew..."
        brew install pkgxdev/made/pkgx || exit_with_error "Installation of pkgx using Homebrew failed."
    elif command_exists curl; then
        echo_with_color "34" "Installing pkgx using curl..."
        curl -Ssf https://pkgx.sh | sh || exit_with_error "Installation of pkgx using curl failed."
    else
        exit_with_error "Homebrew and curl are not installed. Cannot install pkgx."
    fi
}

# Check if pkgx is installed, if not then install it
if ! command_exists pkgx; then
    echo_with_color "31" "pkgx could not be found"
    install_pkgx
fi

# Verify if pkgx was successfully installed
command_exists pkgx || exit_with_error "pkgx installation failed."


# List of packages to install

#### Need to add unzip and make but for linux only
packages=(
    "aiac"
    "asciinema"
    "atlasgo.io"
    "awk"
    "aws"
    "aws-vault"
    "aws-whoami"
    "awslogs"
    "bash"
    "bashbug"
    "bat"
    "bore.pub"
    "broot"
    "btm"
    "chezmoi.io"
    "click"
    "cloc"
    "cog"
    "commit"
    "config_data"
    "csview"
    "cw"
    "dialog"
    "dblab"
    "direnv"
    "diskus"
    "diskonaut"
    "dive"
    "docker-clean"
    # "docker-compose" # installed via podman desktop at /usr/local/bin
    "dog"
    "dua"
    "duf"
    "enc"
    "exa"
    "eza"
    "fblog"
    "fd"
    "fend"
    "find"
    "fish"
    "fish_indent"
    "fish_key_reader"
    "fnm"
    "fselect"
    "fx"
    "fzf"
    "gawk"
    "gh"
    "ghq"
    "git"
    "git-cvsserver"
    "git-gone"
    "git-quick-stats"
    "git-receive-pack"
    "git-shell"
    "git-town"
    "git-trim"
    "git-upload-archive"
    "git-upload-pack"
    "gitleaks"
    "gitopolis"
    "gitui"
    "gitweb"
    "glow"
    "go"
    "gofmt"
    "gum"
    "helm"
    "htop"
    "http"
    "httpie"
    "https"
    "hurl"
    "hurlfmt"
    "jetp"
    "jq"
    "just"
    "k3sup"
    "k6"
    "k9s"
    "killport"
    "kind"
    "kubectl"
    "kubectl-krew"
    "kubeshark"
    "lazygit"
    "lego"
    "locate"
    "lsd"
    "mackup"
    "mash" # scripthub
    "melt"
    "micro"
    "mongosh"
    "mprocs"
    "ncat"
    "neofetch"
    "nmap"
    "nping"
    "nushell.sh"
    "neovim.io"
    "onefetch"
    "packer"
    "pls"
    "pgen"
    "pipx"
    "pre-commit"
    "rclone"
    "rg"
    "scalar"
    "sd"
    "shellcheck"
    "starship"
    "steampipe"
    "stern"
    "tldr"
    "tmux"
    "toast"
    "tofu"
    "tree"
    "trufflehog"
    "tv"
    "updatedb"
    "usql"
    "vals"
    "vault"
    "wget"
    "when"
    "xargs"
    "xcfile.dev"
    "yazi"
    "yj"
    "zap"
    "zellij"
    "zoxide"
    # install these packages last to address identical binary
    "midnight-commander.org"
    "min.io/mc"
)

# Linux specific packages
if [ "$(get_os)" = "Linux" ]; then
    packages+=("unzip" "make" "nano")
fi

# Binary paths (edit these as per your system)
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "34" "Installing packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    # Capture the output of the package installation
    output=$(pkgx install "${package}" 2>&1)

    if [[ "${output}" == *"pkgx: installed:"* ]]; then
        echo_with_color "32" "${package} installed successfully"

        # If the package is mc (Midnight Commander), rename the binary
        if [ "${package}" = "midnight-commander.org" ]; then
            mv "${mc_bin_path}" "${mcomm_bin_path}" || exit_with_error "Failed to rename mc binary to mcomm."
            echo_with_color "32" "Renamed mc binary to mcomm"
        fi
    elif [[ "${output}" == *"pkgx: already installed:"* ]]; then
        echo_with_color "34" "${package} is already installed."
    else
        echo_with_color "31" "Failed to install ${package}: $output"
    fi
done

# Add $HOME/.local/bin to PATH if it's not already there
add_to_path "$HOME/.local/bin"

