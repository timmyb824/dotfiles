#!/bin/bash

# Check if pkgx is installed
if ! command -v pkgx &> /dev/null; then
    echo "pkgx could not be found"

    # Check for Homebrew and install pkgx if Homebrew is available
    if command -v brew &> /dev/null; then
        echo "Installing pkgx using Homebrew..."
        brew install pkgxdev/made/pkgx

    # If Homebrew is not available, check for curl and install pkgx using the script
    elif command -v curl &> /dev/null; then
        echo "Installing pkgx using curl..."
        curl -Ssf https://pkgx.sh | sh

    # If neither Homebrew nor curl are available, exit the script with an error
    else
        echo "Error: Homebrew and curl are not installed. Cannot install pkgx."
        exit 1
    fi
fi

# Verify if pkgx was successfully installed
if ! command -v pkgx &> /dev/null; then
    echo "Error: pkgx installation failed."
    exit 1
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

# Add $HOME/.local/bin to PATH if it's not already there
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "Adding $HOME/.local/bin to PATH for the current session..."
    export PATH="$HOME/.local/bin:$PATH"
fi

# Persistently add $HOME/.local/bin to PATH in the shell's profile file
# Choose .bashrc, .zshrc, or other relevant shell configuration file
PROFILE_FILE="$HOME/.bashrc"
if ! grep -q "$HOME/.local/bin" "$PROFILE_FILE"; then
    echo "Adding $HOME/.local/bin to PATH in $PROFILE_FILE for future sessions..."
    echo "# Add local bin to PATH" >> "$PROFILE_FILE"
    echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$PROFILE_FILE"
fi

echo "Installation completed and $HOME/.local/bin added to PATH."
