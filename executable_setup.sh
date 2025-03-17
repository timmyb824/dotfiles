#!/usr/bin/env bash

###################
#### VARIABLES ####
###################

CHEZMOI_BIN="$(command -v chezmoi)" || "/usr/local/bin/chezmoi"
DOTFILES_REPO="timmyb824/dotfiles"
SOPS_VERSION="3.9.4"
AGE_VERSION="1.2.1"
CURRENT_USER=$(whoami)
export CURRENT_USER
export PRIVILEGED_USERS=("tbryant" "timmyb824" "remoter" "timothybryant" "timothy.bryant")
export AGE_RECIPIENT="op://Personal/age-secret-key/username"
export AGE_SECRET_KEY="op://Personal/age-secret-key/credential"
export AGE_SECRET_KEY_FILE="op://Personal/age-secret-key-file/age-master-key.txt"
export AGE_SECRET_KEY_LOCATION="$HOME/.sops/age-master-key.txt"
export CHEZMOI_CONFIG_FILE="op://Personal/chezmoi-toml-config/chezmoi.toml"
export CHEZMOI_CONFIG_FILE_LOCATION="$HOME/.config/chezmoi/chezmoi.toml"

##########################
#### GLOBAL FUNCTIONS ####
##########################

msg_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

msg_ok() {
    echo -e "\033[1;32m[OK]\033[0m $1"
}

msg_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

msg_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

handle_error() {
    msg_error "$1"
    exit 1
}

command_exists() {
    command -v "$1" &>/dev/null
}

ask_yes_or_no() {
    while true; do
        read -p "$1 (y/N): " -n 1 -r
        echo
        case "$REPLY" in
        [yY])
            return 0
            ;;
        [nN] | "")
            return 1
            ;;
        *)
            msg_warn "Please answer yes or no."
            ;;
        esac
    done
}

safe_remove_command() {
    local cmd_path
    cmd_path=$(command -v "$1") || return 0
    if [[ -n $cmd_path ]]; then
        sudo rm "$cmd_path" && msg_ok "$1 removed successfully." || handle_error "Failed to remove $1."
    fi
}

get_os() {
    case "$(uname -s)" in
    Linux*) echo "Linux" ;;
    Darwin*) echo "MacOS" ;;
    *) echo "Unknown" ;;
    esac
}

is_privileged_user() {
    for user in "${PRIVILEGED_USERS[@]}"; do
        if [[ "$CURRENT_USER" == "$user" ]]; then
            return 0 # The user is privileged
        fi
    done
    return 1 # The user is not privileged
}

1password_sign_in() {
    if eval "$(op signin)"; then
        msg_ok "Successfully signed into 1Password CLI."
    else
        msg_error "Failed to sign in to 1Password"
        return 1
    fi
}

################
#### SCRIPT ####
################

OS=$(get_os)

install_op_cli_macos() {
    if command_exists op; then
        msg_warn "The 1Password CLI is already installed."
        return 0 # Indicate that it's already installed
    fi

    msg_ok "Installing the 1Password CLI for macOS..."

    # Check for required download commands
    if ! command_exists curl && ! command_exists wget; then
        msg_error "Error: 'curl' or 'wget' is required to download files."
        return 1
    fi

    # Determine download tool
    local download_cmd=""
    if command_exists curl; then
        download_cmd="curl -Lso"
    elif command_exists wget; then
        download_cmd="wget --quiet -O"
    fi

    # Download the latest release of the 1Password CLI
    local op_cli_pkg="op_apple_universal_v2.24.0.pkg"
    $download_cmd "$op_cli_pkg" "https://cache.agilebits.com/dist/1P/op2/pkg/v2.24.0/$op_cli_pkg"

    # Install the package
    sudo installer -pkg "$op_cli_pkg" -target /

    # Verify the installation
    if command_exists op; then
        msg_ok "The 1Password CLI was installed successfully."
    else
        msg_error "Error: The 1Password CLI installation failed."
        return 1
    fi
}

install_op_cli_linux() {
    if command_exists op; then
        msg_warn "The 1Password CLI is already installed."
        return 0 # Indicate that it's already installed
    fi

    if command_exists curl; then
        msg_ok "The 'curl' command is installed."
    else
        msg_info "Installing the 'curl' command..."
        sudo apt update && sudo apt install -y curl
    fi

    if ! command_exists gpg; then
        msg_info "Installing GPG..."
        sudo apt update && sudo apt install -y gnupg
    fi

    # Install the 1Password CLI using the new steps provided
    if ! sudo sh -c 'curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
tee /etc/apt/sources.list.d/1password.list && \
mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
apt update && apt install -y 1password-cli'; then
        msg_error "Error: The 1Password CLI installation failed."
        return 1
    fi

    if ! command_exists op; then
        msg_error "Error: The 'op' command does not exist after attempting installation."
        return 1
    else
        msg_ok "The 1Password CLI was installed successfully."
    fi
}

install_1password() {
    msg_info "Installing 1Password CLI..."
    case "$OS" in
    "MacOS")
        install_op_cli_macos
        ;;
    "Linux")
        install_op_cli_linux
        ;;
    *)
        handle_error "Unsupported operating system: $OS"
        ;;
    esac
}

install_age_sops() {
    case "$OS" in
    "MacOS")
        install_age_macos
        install_sops_macos
        ;;
    "Linux")
        install_age_linux
        install_sops_linux
        ;;
    *)
        handle_error "Unsupported operating system: $OS"
        ;;
    esac
}

install_chezmoi() {
    msg_info "Installing chezmoi..."
    if command_exists chezmoi; then
        msg_warn "chezmoi is already installed."
        return 0
    fi

    if command_exists curl; then
        sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
    elif command_exists wget; then
        sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b /usr/local/bin
    else
        handle_error "neither curl nor wget is available."
    fi

    msg_ok "chezmoi has been installed successfully."
}

# Function to install sops on macOS
install_sops_macos() {
    if command_exists sops; then
        msg_warn "sops is already installed on macOS."
        return 0
    fi

    local sops_binary="sops-${SOPS_VERSION}.darwin.arm64"
    msg_info "Downloading sops binary for macOS..."
    curl -LO "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${sops_binary}"
    sudo mv "$sops_binary" /usr/local/bin/sops
    sudo chmod +x /usr/local/bin/sops
    msg_ok "sops installed successfully on macOS."
}

# Function to install age on macOS
install_age_macos() {
    if command_exists age; then
        msg_warn "age is already installed on macOS."
        return 0
    fi

    local age_archive="age-${AGE_VERSION}-darwin-arm64.tar.gz"
    msg_info "Downloading age binary for macOS..."
    curl -LO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${age_archive}"
    tar -xvf "$age_archive"
    sudo mv age/age /usr/local/bin/age
    rm -rf age
    rm -f "$age_archive"
    msg_ok "age installed successfully on macOS."
}

# Function to install sops on Linux
install_sops_linux() {
    if command_exists sops; then
        msg_warn "sops is already installed on Linux."
        return 0
    fi

    msg_info "Downloading sops binary for Linux..."
    SOPS_BINARY="sops-${SOPS_VERSION}.linux.amd64"
    SOPS_URL="https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"

    if curl -LO "$SOPS_URL"; then
        sudo mv "$SOPS_BINARY" /usr/local/bin/sops
        sudo chmod +x /usr/local/bin/sops
        msg_ok "sops installed successfully on Linux."
    else
        msg_error "Error: Failed to download sops from the URL: $SOPS_URL"
        return 1
    fi
}

# Function to install age on Linux
install_age_linux() {
    if command_exists age; then
        msg_warn "age is already installed on Linux."
        return 0
    fi

    msg_info "Downloading age binary for Linux..."
    AGE_BINARY="age-${AGE_VERSION}-linux-amd64.tar.gz"
    AGE_URL="https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${AGE_BINARY}"

    if curl -LO "$AGE_URL"; then
        tar -xvf "$AGE_BINARY"
        sudo mv age/age /usr/local/bin/age
        rm -rf age "$AGE_BINARY"
        msg_ok "age installed successfully on Linux."
    else
        msg_error "Error: Failed to download age from the URL: $AGE_URL"
        return 1
    fi
}

initialize_chezmoi() {
    msg_info "Initializing chezmoi dotfiles."
    if "$CHEZMOI_BIN" init "$DOTFILES_REPO" && "$CHEZMOI_BIN" apply; then
        msg_ok "chezmoi dotfiles have been applied successfully."
    else
        handle_error "chezmoi dotfiles could not be initialized or applied."
    fi
}

create_age_secret_key() {
    if [ ! -f "$AGE_SECRET_KEY_LOCATION" ]; then
        msg_info "Creating age secret key..."
        mkdir -p "$(dirname "$AGE_SECRET_KEY_LOCATION")"

        # Attempt to read the age secret key and store it in a variable
        local age_secret_key
        if age_secret_key=$(op read "$AGE_SECRET_KEY_FILE" 2>/dev/null); then
            echo "$age_secret_key" >"$AGE_SECRET_KEY_LOCATION"
            msg_ok "Age secret key created successfully."
        else
            msg_error "Failed to create age secret key."
            return 1
        fi
    else
        msg_warn "The age secret key already exists."
    fi
}

create_age_secret_key_file_unprivileged() {
    if [ ! -f "$AGE_SECRET_KEY_LOCATION" ]; then
        msg_info "Creating age secret key..."
        mkdir -p "$(dirname "$AGE_SECRET_KEY_LOCATION")"

        # Attempt to read the age secret key and store it in a variable
        local age_secret_key_credential
        local age_secret_key_recipient
        if age_secret_key_credential=$(op read "$AGE_SECRET_KEY" 2>/dev/null) && age_secret_key_recipient=$(op read "$AGE_RECIPIENT" 2>/dev/null); then
            # The heredoc delimiter must be unquoted to allow variable expansion.
            # Also, the delimiter must be at the beginning of the line with no leading whitespace.
            sudo tee "$AGE_SECRET_KEY_LOCATION" >/dev/null <<EOF
# created: $(date -Iseconds)
# public key: ${age_secret_key_recipient}
${age_secret_key_credential}
EOF
            msg_ok "Age secret key created successfully."
        else
            msg_error "Failed to create age secret key."
            return 1
        fi
    else
        msg_warn "The age secret key already exists."
    fi
}

create_chezmoi_config() {
    if [ ! -f "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
        msg_info "Creating chezmoi config file..."
        mkdir -p "$(dirname "$CHEZMOI_CONFIG_FILE_LOCATION")"
        if op read "$CHEZMOI_CONFIG_FILE" 2>/dev/null >"$CHEZMOI_CONFIG_FILE_LOCATION"; then
            msg_ok "Chezmoi config file created successfully."
        else
            msg_error "Failed to create chezmoi config file."
            return 1
        fi
    else
        msg_warn "The chezmoi config file already exists."
    fi
}

######################
#### MAIN SCRIPT #####
######################

# Early exit if chezmoi is already set up
if [[ -d "$HOME/.local/share/chezmoi" && -f "$HOME/.zshrc" ]]; then
    msg_warn "It appears chezmoi is already installed and initialized."
    exit 0
fi

# Ensure required environment variables are set
if [ -z "$AGE_SECRET_KEY_LOCATION" ] || [ -z "$AGE_SECRET_KEY_FILE" ]; then
    handle_error "Required age secret key environment variables are not set."
fi

if [ -z "$CHEZMOI_CONFIG_FILE" ] || [ -z "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
    handle_error "Required chezmoi config environment variables are not set."
fi

# Install and configure 1Password
msg_info "Installing 1Password CLI..."
install_1password || handle_error "Failed to install 1Password CLI"

# Sign in to 1Password
msg_info "Signing in to 1Password..."
1password_sign_in || handle_error "Failed to sign in to 1Password"

# Install age and sops
msg_info "Installing age and sops..."
install_age_sops || handle_error "Failed to install age and sops"

# Create age secret key file based on privilege level
msg_info "Creating age secret key..."
if is_privileged_user; then
    create_age_secret_key || handle_error "Failed to create age secret key"
else
    create_age_secret_key_file_unprivileged || handle_error "Failed to create age secret key"
fi

# Create chezmoi config
msg_info "Creating chezmoi config..."
create_chezmoi_config || handle_error "Failed to create chezmoi config"

# Install and initialize chezmoi
msg_info "Installing and initializing chezmoi..."
install_chezmoi || handle_error "Failed to install chezmoi"
initialize_chezmoi || handle_error "Failed to initialize chezmoi"

# Handle binary cleanup based on OS
if [[ "$OS" == "MacOS" ]]; then
    if ask_yes_or_no "Do you want to remove the 1password, chezmoi, sops, and age binaries (if installing later with homebrew)?"; then
        msg_info "Removing binaries..."
        safe_remove_command "$CHEZMOI_BIN"
        safe_remove_command "/usr/local/bin/sops"
        safe_remove_command "/usr/local/bin/age"
        safe_remove_command "/usr/local/bin/op"
    else
        msg_info "Skipping binary removal."
    fi
else
    if ask_yes_or_no "Do you want to remove the chezmoi, sops, and age binaries (you probably want no)?"; then
        msg_info "Removing binaries..."
        safe_remove_command "$CHEZMOI_BIN"
        safe_remove_command "/usr/local/bin/sops"
        safe_remove_command "/usr/local/bin/age"
    else
        msg_info "Skipping binaries removal."
    fi
fi

msg_ok "Setup completed successfully!"
