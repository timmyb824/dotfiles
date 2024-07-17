#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Promtail
install_promtail() {
    local version=$1
    local deb_file="promtail_${version}_amd64.deb"
    local download_url="https://github.com/grafana/loki/releases/download/v${version}/${deb_file}"

    echo_with_color "$GREEN" "Starting Promtail installation..."

    # Downloading Promtail .deb package
    echo_with_color "$GREEN" "Downloading Promtail version ${version}..."
    if ! wget "${download_url}" -O "${deb_file}" 2>/dev/null; then
        echo_with_color "$RED" "Failed to download Promtail .deb package"
        return 1
    fi
    echo_with_color "$GREEN" "Download complete."

    # Install the downloaded .deb package
    echo_with_color "$GREEN" "Installing Promtail..."
    if ! sudo dpkg -i "${deb_file}"; then
        echo_with_color "$RED" "Failed to install Promtail"
        # Attempt to fix any missing dependencies and finish the installation
        sudo apt-get install -f
    else
        echo_with_color "$GREEN" "Promtail installation completed successfully."
    fi

    # Cleanup downloaded package
    echo_with_color "$GREEN" "Cleaning up..."
    rm "${deb_file}"
    echo_with_color "$GREEN" "Cleanup complete."
}

create_promtail_user() {
    # check if promtail user exists and create it if it doesn't
    echo_with_color "$GREEN" "Checking for promtail user..."
    if ! id promtail &>/dev/null; then
        echo_with_color "$YELLOW" "Promtail user not found. Creating promtail user..."
        sudo useradd --system promtail || echo_with_color "$RED" "Failed to create promtail user."
    fi
    echo_with_color "$GREEN" "Promtail user found."
}

add_promtail_to_groups() {
    echo_with_color "$GREEN" "Adding promtail user to the adm group..."
    sudo usermod -aG adm promtail || echo_with_color "$RED" "Failed to add promtail user to the adm group."
    echo_with_color "$GREEN" "Adding promtail user to the systemd-journal group..."
    sudo usermod -aG systemd-journal promtail || echo_with_color "$RED" "Failed to add promtail user to the systemd-journal group."
    echo_with_color "$GREEN" "Added promtail user to the adm and systemd-journal groups."
}

configure_promtail() {
    local LOKI_URL="$LOKI_URL"

    # Check if a LOKI_URL is provided
    if [ -z "$LOKI_URL" ]; then
        echo "LOKI_URL is not set."
        return 1
    fi

    # Use your function echo_with_color if it's defined, or just echo otherwise
    if command -v echo_with_color &> /dev/null; then
        echo_with_color "$GREEN" "Configuring Promtail..."
    else
        echo "Configuring Promtail..."
    fi

    # Make a backup of the original Promtail config
    sudo cp /etc/promtail/config.yml /etc/promtail/config.yml.bak

    # Write the new Promtail configuration to the file
    sudo tee /etc/promtail/config.yml > /dev/null <<EOF
    server:
      http_listen_port: 9080
      grpc_listen_port: 0

    positions:
      filename: /tmp/positions.yaml

    clients:
      - url: ${LOKI_URL}
        external_labels:
          host: $(hostname)

    scrape_configs:

    - job_name: system
      static_configs:
      - targets:
          - localhost
        labels:
          job: syslog
          __path__: /var/log/syslog

    - job_name: journal
      journal:
        json: false
        max_age: 12h
        path: /var/log/journal
        labels:
          job: systemd-journal
      relabel_configs:
        - source_labels: ['__journal__systemd_unit']
          target_label: 'unit'
EOF
}

upgrade_promtail() {
    local version=$1
    local deb_file="promtail_${version}_amd64.deb"
    local download_url="https://github.com/grafana/loki/releases/download/v${version}/${deb_file}"

    echo_with_color "$GREEN" "Starting Promtail upgrade..."
    if ! wget "${download_url}" -O "${deb_file}" 2>/dev/null; then
        echo_with_color "$RED" "Failed to download Promtail .deb package"
        return 1
    fi

    echo_with_color "$GREEN" "Download complete. Upgrading Promtail..."
    if ! sudo dpkg -i "${deb_file}"; then
        echo_with_color "$RED" "Failed to upgrade Promtail"
        sudo apt-get install -f
    else
        echo_with_color "$GREEN" "Promtail upgrade completed successfully."
    fi

    echo_with_color "$GREEN" "Cleaning up..."
    rm "${deb_file}"
    echo_with_color "$GREEN" "Cleanup complete."
}

# create function restart promtail
restart_promtail() {
    echo_with_color "$GREEN" "Restarting Promtail..."
    sudo systemctl daemon-reload || echo_with_color "$RED" "Failed to reload systemd."
    sudo systemctl restart promtail || echo_with_color "$RED" "Failed to restart Promtail."
    echo_with_color "$GREEN" "Promtail restarted."
}

if ! command_exists promtail; then
    install_promtail "$PROMTAIL_VERSION"

    create_promtail_user

    add_promtail_to_groups

    configure_promtail

    restart_promtail
else
    # check if the installed version is the same as the desired version
    if [ "$(promtail --version | grep 'promtail, version' | awk '{print $3}')" != "$PROMTAIL_VERSION" ]; then
        echo_with_color "$YELLOW" "Promtail is already installed but the version is different."
        upgrade_promtail "$PROMTAIL_VERSION"
        restart_promtail
    else
        echo_with_color "$GREEN" "Promtail is already installed and up-to-date."
    fi
fi
