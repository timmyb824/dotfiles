#!/Users/timothybryant/.local/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

########## INSTALLATION STEPS ##########

# Function to download and install 1Password CLI on macOS
install_op_cli_macos() {
    if command_exists op; then
        echo_with_color "33" "The 1Password CLI is already installed."
        return 0 # Indicate that it's already installed
    else
        echo_with_color "32" "Installing the 1Password CLI for macOS..."

        # Determine download tool
        if command_exists curl; then
            DOWNLOAD_CMD="curl -Lso"
        elif command_exists wget; then
            DOWNLOAD_CMD="wget --quiet -O"
        else
            echo_with_color "31" "Error: 'curl' or 'wget' is required to download files."
            return 1
        fi

        # Download the latest release of the 1Password CLI
        OP_CLI_PKG="op_apple_universal_v2.24.0.pkg"
        $DOWNLOAD_CMD "$OP_CLI_PKG" "https://cache.agilebits.com/dist/1P/op2/pkg/v2.24.0/$OP_CLI_PKG"

        # Install the package
        sudo installer -pkg "$OP_CLI_PKG" -target /

        # Verify the installation
        if command_exists op; then
            echo "The 1Password CLI was installed successfully."
        else
            echo "Error: The 1Password CLI installation failed."
            return 1
        fi
    fi
}

install_op_cli_linux() {
    # Install the 1Password CLI using the new steps provided
    if ! sudo -s -- <<EOF
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
tee /etc/apt/sources.list.d/1password.list
mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
apt update && apt install -y 1password-cli
EOF
    then
        echo "Error: The 1Password CLI installation failed."
        return 1
    fi

    if ! command_exists op; then
        echo "Error: The 'op' command does not exist after attempting installation."
        return 1
    else
        echo "The 1Password CLI was installed successfully."
    fi
}

OS=$(get_os)
INSTALL_SUCCESS=0 # Default value assuming success

if [ "$OS" = "Linux" ]; then
    if ! command_exists op; then
        echo "Installing the 1Password CLI for Linux..."
        install_op_cli_linux
        INSTALL_SUCCESS=$?
    else
        echo "The 1Password CLI is already installed."
    fi
elif [ "$OS" = "MacOS" ]; then
    install_op_cli_macos
    INSTALL_SUCCESS=$?
else
    echo "This script only supports Linux and macOS systems."
    exit 1
fi

# Exit if installation failed or if we're on macOS (no further steps required)
if [ "$INSTALL_SUCCESS" -ne 0 ] || [ "$OS" = "Darwin" ]; then
    echo "Installation failed or completed for macOS. Exiting."
    exit $INSTALL_SUCCESS
fi

########## CONFIGURATION STEPS ##########

if ask_yes_or_no "Would you like to configure 1Password CLI?"; then
    echo_with_color "32" "Configuring 1Password CLI..."

    read -sp "1Password email: " OP_EMAIL
    echo
    read -sp "1Passwored Secret Key: " OP_SECRET_KEY
    echo
    read -sp "1Password Signin Address: " OP_SIGNIN_ADDRESS
    echo

    # Sign in to your 1Password account to obtain a session token
    # The session token is output to STDOUT, so we capture it in a variable
    OP_SESSION_TOKEN=$(op account add --address $OP_SIGNIN_ADDRESS --email $OP_EMAIL --secret-key $OP_SECRET_KEY --shorthand personal --signin --raw)
    export OP_SESSION_TOKEN

    # Check if sign-in was successful
    if [[ -z "$OP_SESSION_TOKEN" ]]; then
        echo "Failed to sign in to 1Password CLI."
        exit 1
    fi
else
    echo_with_color "33" "Skipping 1Password CLI configuration."
fi

########## USAGE ##########

process_file() {
    local file_path="$1"
    local output_path="$2"

    while IFS= read -r line; do
        if [[ "$line" == *"onepasswordRead"* ]]; then
            # Extract the 1Password path
            local op_path=$(echo "$line" | grep -oP '(?<=onepasswordRead ").*(?=" }})')
            if [[ -n "$op_path" ]]; then
                # Fetch the secret from 1Password
                local secret=$(op read "$op_path" --session="$OP_SESSION_TOKEN")
                if [[ -n "$secret" ]]; then
                    # Replace the placeholder with the actual secret value
                    line=${line/\{\{ onepasswordRead \"$op_path\" \}\}/$secret}
                else
                    echo "Error: Unable to retrieve the secret for $op_path"
                    return 1
                fi
            fi
        fi
        echo "$line"
    done < "$file_path" > "$output_path"
}

# Predefined list of source files and their output paths
declare -A file_map
# file_map["/path/to/source/template1.tpl"]="/path/to/output/file1"
file_map["$HOME/dotfiles/dot_aicommits.tmpl"]="$HOME/.aicommits"
file_map["$HOME/dotfiles/dot_dblab.yaml.tmpl"]="$HOME/.dblab.yaml"
file_map["$HOME/dotfiles/dot_opencommit.tmpl"]="$HOME/.opencommit"
file_map["$HOME/dotfiles/dot_config/gitearc/dot_gitearc.tmpl"]="$HOME/.config/.gitearc"
file_map["$HOME/dotfiles/dot_config/wtf/private_config.yml.tmpl"]="$HOME/.config/wtf/config.yml"

if ask_yes_or_no "Do you want to process the templates?"; then
    echo "Processing templates..."

    # Process each file and copy it to the designated output path
    for file_path in "${!file_map[@]}"; do
        output_path="${file_map[$file_path]}"
        if [[ -f "$file_path" ]]; then
            echo "Processing $file_path..."
            process_file "$file_path" "$output_path"
            if [ $? -eq 0 ]; then
                echo "Processed file $file_path and saved as $output_path"
            else
                echo "Failed to process $file_path"
            fi
        else
            echo "File $file_path does not exist."
        fi
    done
else
    echo "Skipping template processing."
    exit 0
fi