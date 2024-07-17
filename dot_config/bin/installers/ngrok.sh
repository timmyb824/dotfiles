#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_ngrok_cli_linux() {
    # Install the ngrok CLI using the new steps provided
    if ! sudo sh -c 'curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	| tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	| tee /etc/apt/sources.list.d/ngrok.list \
	&& apt update \
	&& apt install ngrok'; then
        echo_with_color "$RED_COLOR" "Error: The ngrok CLI installation failed."
        return 1
    fi

    if ! command_exists ngrok; then
        echo_with_color "$RED_COLOR" "Error: The 'ngrok' command does not exist after attempting installation."
        return 1
    else
        echo_with_color "$GREEN_COLOR" "The ngrok CLI was installed successfully."
    fi
}

if command_exists curl; then
    echo_with_color "$GREEN_COLOR" "The 'curl' command is installed."
else
    echo_with_color "$BLUE_COLOR" "Installing the 'curl' command..."
    sudo apt update && sudo apt install -y curl
fi

if ! command_exists ngrok; then
    echo_with_color "$GREEN_COLOR" "Installing the ngrok CLI for Linux..."
    install_ngrok_cli_linux
else
    echo_with_color "$YELLOW_COLOR" "The ngrok CLI is already installed."
fi
