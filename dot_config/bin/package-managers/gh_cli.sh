# #!/usr/bin/env bash

# source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# # create new install function that captures the output of the gh extension install command
# install_gh_extension() {
#     local extension=$1
#     local output
#     output=$(gh extension install "$extension" 2>&1)
#     echo "$output"
#     if [[ $output == *"already installed"* ]]; then
#         echo_with_color "$YELLOW_COLOR" "${extension} already installed; attempting to update"
#         output=$(gh extension upgrade "$extension" 2>&1)
#         echo "$output"
#         if [[ $output == *"upgraded"* ]]; then
#             echo_with_color "$GREEN_COLOR" "${extension} updated successfully"
#         elif [[ $output == *"already up to date"* ]]; then
#             echo_with_color "$YELLOW_COLOR" "${extension} already up to date"
#         else
#             # Instead of exiting, the script will report the error and continue with other plugins
#             echo_with_color "$RED_COLOR" "Failed to update ${extension}"
#             echo_with_color "$RED_COLOR" "$output"
#         fi
#     elif [[ $output == *"Installed extension"* ]] || [[ $output == *"Cloning"* ]]; then
#         echo_with_color "$GREEN_COLOR" "${extension} installed successfully"
#     elif [[ $output == *"To get started with GitHub CLI"* ]] || [[ $output == *"gh auth login"* ]]; then
#         echo_with_color "$YELLOW_COLOR" "Please authenticate with GitHub CLI to install extensions"
#         exit 1
#     else
#         # Instead of exiting, the script will report the error and continue with other plugins
#         echo_with_color "$RED_COLOR" "Failed to install ${extension}"
#         echo_with_color "$RED_COLOR" "$output"
#     fi
# }

# attempt_fix_command "gh" "$HOME/.local/bin"

# if ! command_exists gh; then
#     exit_with_error "gh cli not found"
# else
#     echo_with_color "$GREEN_COLOR" "gh cli found continuing with extensions installation"
# fi

# # Read package list and install plugins
# while IFS= read -r package; do
#     # Trim whitespace and check if the line is not empty before attempting installation
#     trimmed_package=$(echo "$package" | xargs)
#     if [ -n "$trimmed_package" ]; then
#         install_gh_extension "$trimmed_package"
#     fi
# done < <(get_package_list gh_cli)

###################################################################
###################################################################

# #!/usr/bin/env bash

# source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# install_gh_extension() {
#     local extension=$1
#     local output
#     output=$(gh extension install "$extension" 2>&1)
#     echo "$output"

#     if echo "$output" | grep -q "already installed"; then
#         echo_with_color "$YELLOW_COLOR" "${extension} already installed; attempting to update"
#         output=$(gh extension upgrade "$extension" 2>&1)
#         echo "$output"
#         if echo "$output" | grep -q "upgraded"; then
#             echo_with_color "$GREEN_COLOR" "${extension} updated successfully"
#         elif echo "$output" | grep -q "already up to date"; then
#             echo_with_color "$YELLOW_COLOR" "${extension} already up to date"
#         else
#             echo_with_color "$RED_COLOR" "Failed to update ${extension}"
#             echo_with_color "$RED_COLOR" "$output"
#         fi
#     elif echo "$output" | grep -E "Cloning"; then
#         echo_with_color "$GREEN_COLOR" "${extension} installed successfully"
#     elif echo "$output" | grep -E "To get started with GitHub CLI|gh auth login"; then
#         echo_with_color "$YELLOW_COLOR" "Please authenticate with GitHub CLI to install extensions"
#         exit 1
#     else
#         echo_with_color "$RED_COLOR" "Failed to install ${extension}"
#         echo_with_color "$RED_COLOR" "$output"
#     fi
# }

# attempt_fix_command "gh" "$HOME/.local/bin"

# if ! command_exists gh; then
#     exit_with_error "gh cli not found"
# else
#     echo_with_color "$GREEN_COLOR" "gh cli found continuing with extensions installation"
# fi

# # Read package list and install plugins
# while IFS= read -r package; do
#     trimmed_package=$(echo "$package" | xargs)
#     if [ -n "$trimmed_package" ]; then
#         install_gh_extension "$trimmed_package"
#     fi
# done < <(get_package_list gh_cli)

###################################################################
###################################################################

#!/usr/bin/env bash

# Load initialization script
source "$(dirname "${BASH_SOURCE[0]}")/../init/init.sh"

# Check login status and log in if necessary
gh_login_status() {
    if ! gh auth status | grep -q "Logged in"; then
        echo_with_color "$YELLOW_COLOR" "You are not logged in. Attempting to authenticate with GitHub CLI..."
        read -r -p "Enter your GitHub CLI token: " gh_token
        echo "$gh_token" >/tmp/gh_token.txt
        if ! gh auth login --with-token </tmp/gh_token.txt; then
            exit_with_error "Failed to authenticate with GitHub CLI."
        fi
        rm /tmp/gh_token.txt
        echo_with_color "$GREEN_COLOR" "You have successfully logged in."
    else
        echo_with_color "$GREEN_COLOR" "You are already logged in."
    fi
}

# Function to install or update a GitHub CLI extension
install_gh_extension() {
    local extension="$1"
    echo_with_color "$BLUE_COLOR" "Installing gh extension: $extension"

    if gh extension list | grep -q "$extension"; then
        echo_with_color "$YELLOW_COLOR" "Extension $extension already installed. Attempting to update..."
        if gh extension upgrade "$extension"; then
            echo_with_color "$GREEN_COLOR" "Extension $extension updated successfully."
        else
            echo_with_color "$RED_COLOR" "Failed to update extension $extension."
        fi
    else
        if gh extension install "$extension"; then
            echo_with_color "$GREEN_COLOR" "Extension $extension installed successfully."
        else
            echo_with_color "$RED_COLOR" "Failed to install extension $extension."
        fi
    fi
}

# Function to ensure a command exists, attempt to fix if not
attempt_fix_command "gh" "$HOME/.local/bin"

# Check if the gh CLI is available
if ! command_exists gh; then
    exit_with_error "gh CLI not found."
else
    echo_with_color "$GREEN_COLOR" "gh CLI found. Continuing with extensions installation..."
fi

# Check login status and log in if necessary
gh_login_status

# Read package list and install extensions
while IFS= read -r package; do
    trimmed_package=$(echo "$package" | xargs)
    if [ -n "$trimmed_package" ]; then
        install_gh_extension "$trimmed_package"
    fi
done < <(get_package_list gh_cli)
