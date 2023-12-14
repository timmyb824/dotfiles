#!/bin/bash

# Check if pkgx is installed
if ! command -v pkgx &> /dev/null
then
    echo "pkgx could not be found"
    exit
fi

# List of packages to install
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
    "mprocs"
    "ncat"
    "neofetch"
    "nmap"
    "nping"
    "nushell.sh"
    "neovim.io"
    "onefetch"
    "packer"
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


# Binary paths (edit these as per your system)
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo "Installing packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"
do
    # Capture the output of the package installation
    output=$(pkgx install "${package}" 2>&1)

    if [[ "${output}" == *"pkgx: installed:"* ]]; then
        echo "${package} installed successfully"

        # If the package is mc (Midnight Commander), rename the binary
        if [ "${package}" = "midnight-commander.org" ]; then
            mv "${mc_bin_path}" "${mcomm_bin_path}"
            echo "Renamed mc binary to mcomm"
        fi
    elif [[ "${output}" == *"pkgx: already installed:"* ]]; then
        # Don't do anything, package is already installed
        :
    else
        echo "Failed to install ${package}"
    fi
done
