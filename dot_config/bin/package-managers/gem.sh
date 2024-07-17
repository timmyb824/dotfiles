#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

initialize_gem_linux() {
    if command_exists gem; then
        echo_with_color "$GREEN_COLOR" "gem is already installed."
        return
    fi

    echo_with_color "$GREEN" "Initializing rbenv for the current Linux session..."
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
}

initialize_gem_macos() {
    if command_exists gem; then
        echo_with_color "$GREEN_COLOR" "gem is already installed."
        return
    fi

    if command_exists rbenv; then
        echo_with_color "$GREEN_COLOR" "Adding rbenv to PATH."
        eval "$(rbenv init -)"
    else
        exit_with_error "rbenv is not available."
    fi
}

# Function to confirm Ruby version and gem availability
confirm_ruby_and_gem() {
    local version
    version=$(ruby -v 2>&1 | awk '{print $2}')
    if [[ "$version" == "$RUBY_VERSION" ]]; then
        echo_with_color "$GREEN_COLOR" "Confirmed Ruby version ${version}."
    else
        exit_with_error "Ruby version ${version} does not match the desired version ${RUBY_VERSION}."
    fi

    if command_exists gem; then
        echo_with_color "$GREEN_COLOR" "gem is available."
    else
        exit_with_error "gem is not available."
    fi
}

# Function to install gem packages
install_gem_packages() {
    while IFS= read -r package; do
        if [ -z "$package" ]; then  # Skip empty lines
            continue
        fi
        if gem install "$package"; then
            echo_with_color "$GREEN_COLOR" "${package} installed successfully."
        else
            exit_with_error "Failed to install ${package}."
        fi
    done < <(get_package_list gem)
}

if [[ "$OS" == "MacOS" ]]; then
    add_brew_to_path
    initialize_gem_macos
elif [[ "$OS" == "Linux" ]]; then
    initialize_gem_linux
else
    exit_with_error "Unsupported operating system: $OS"
fi

confirm_ruby_and_gem
install_gem_packages
