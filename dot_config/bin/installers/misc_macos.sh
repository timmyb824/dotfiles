#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_plandex_cli() {
    if ! command_exists "plandex"; then
        echo_with_color "$YELLOW_COLOR" "plandex-cli is not installed."
        ask_yes_or_no "Do you want to install plandex-cli?"
        if [[ "$?" -eq 0 ]]; then
            if ! curl -sS https://plandex.ai/install.sh | bash; then
                echo_with_color "$RED_COLOR" "Failed to install plandex-cli."
            else
                echo_with_color "$GREEN_COLOR" "plandex-cli installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping plandex-cli installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "plandex-cli is already installed."
    fi
}

install_teller() {
    local teller_version="2.0.7"
    local teller_url="https://github.com/tellerops/teller/releases/download/v${teller_version}/teller-aarch64-macos.tar.xz"

    if ! command_exists teller; then
        echo_with_color "$YELLOW_COLOR" "teller is not installed."
        ask_yes_or_no "Do you want to install teller?"

        if [[ "$?" -eq 0 ]]; then
            if ! curl -L -sS "$teller_url" -o teller.tar.gz; then
                echo_with_color "$RED_COLOR" "Failed to download teller."
            else
                echo_with_color "$GREEN_COLOR" "Installing teller..."
                tar -xf teller.tar.gz
                sudo mv teller-aarch64-macos/teller /usr/local/bin
                rm -rf teller-aarch64-macos
                rm -rf teller.tar.gz
                echo_with_color "$GREEN_COLOR" "teller installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping teller installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "teller is already installed."
    fi
}


# check for dependencies
if ! command_exists "curl"; then
    exit_with_error "curl is required"
fi

install_plandex_cli
install_teller
