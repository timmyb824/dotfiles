#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../init/init.sh"

USER="$CURRENT_USER"
WORKING_DIR="/home/${USER}/glances"
PYENV_BIN="/home/${USER}/.pyenv/bin/pyenv"

initialize_pyenv() {
    # Initialize pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

create_directories() {
    echo_with_color "$GREEN_COLOR" "Creating directories..."
    for dir in "/home/${USER}/.config" "/home/${USER}/.config/glances" "/home/${USER}/glances"; do
        if ! [ -d "$dir" ]; then
            if ! mkdir -p "$dir"; then
                exit_with_error "Failed to create directory: $dir"
            fi
            chown -R "${USER}:${USER}" "$dir" || exit_with_error "Failed to set ownership for directory: $dir"
        fi
    done
}

create_virtualenv() {
    echo_with_color "$GREEN_COLOR" "Creating glances virtualenv..."
    if ! command_exists pyenv; then
        echo_with_color "$YELLOW_COLOR" "pyenv command not found. Attempting to initialize pyenv..."
        initialize_pyenv || exit_with_error "Failed to initialize pyenv."
        if ! command_exists pyenv; then
            exit_with_error "pyenv command still not found. Please make sure it is installed."
        fi
    fi

    if ! $PYENV_BIN virtualenv "${PYTHON_VERSION}" glances; then
        exit_with_error "Failed to create virtual environment."
    fi

    if ! $PYENV_BIN local glances; then
        exit_with_error "Failed to set local virtual environment."
    fi
}

install_dependencies() {
    echo_with_color "$GREEN_COLOR" "Installing glances dependencies..."
    if ! command_exists pip; then
        exit_with_error "pip command not found. Please make sure it is installed in your virtual environment."
    fi

    if ! $PYENV_BIN exec pip install glances docker podman influxdb influxdb-client bottle prometheus_client requests netifaces; then
        exit_with_error "Failed to install glances dependencies."
    fi
}

create_config_file() {
    echo ""
    read -r -p "Enter your InfluxDB token: " INFLUXDB_TOKEN
    echo ""
    read -r -p "Enter your Podman UNIX socket path e.g. unix:///run/user/1000/podman/podman.sock (leave blank if not using Podman): " PODMAN_UNIX
    echo_with_color "$GREEN_COLOR" "Creating glances config file..."
    cat >/home/"${USER}"/.config/glances/glances.conf <<EOL
[global]
refresh=2
check_update=true
history_size=1200
#strftime_format="%Y-%m-%d %H:%M:%S %Z"
#plugin_dir=/home/user/dev/plugins

[quicklook]
disable=False
list=cpu,mem,load
bar_char=|
cpu_careful=50
cpu_warning=70
cpu_critical=90
mem_careful=50
mem_warning=70
mem_critical=90
swap_careful=50
swap_warning=70
swap_critical=90
load_careful=70
load_warning=100
load_critical=500

[system]

disable=False
#refresh=60
#system_info_msg= | My {os_name} system |

[cpu]
disable=False
total_careful=65
total_warning=75
total_critical=85
total_log=True
user_careful=50
user_warning=70
user_critical=90
user_log=False
system_careful=50
system_warning=70
system_critical=90
system_log=False
steal_careful=50
steal_warning=70
steal_critical=90

[percpu]
disable=False
max_cpu_display=4
user_careful=50
user_warning=70
user_critical=90
iowait_careful=50
iowait_warning=70
iowait_critical=90
system_careful=50
system_warning=70
system_critical=90

[gpu]
disable=True

[mem]
disable=False
careful=50
warning=70
critical=90

[memswap]
disable=False
careful=50
warning=70
critical=90

[load]
disable=False
careful=0.7
warning=1.0
critical=5.0
#log=False

[network]
disable=False
rx_careful=70
rx_warning=80
rx_critical=90
tx_careful=70
tx_warning=80
tx_critical=90
hide=docker.*,lo


[ip]
# Disable display of private IP address
disable=False
public_disabled=True

[connections]
# This plugin is disabled by default because it consumes lots of CPU
disable=True
nf_conntrack_percent_careful=70
nf_conntrack_percent_warning=80
nf_conntrack_percent_critical=90

[wifi]
disable=True

[diskio]
disable=False
hide=loop.*,/dev/loop.*


[fs]
disable=False
hide=/boot.*,.*/snap.*
careful=50
warning=70
critical=90

[irq]
disable=True

[folders]
disable=False
#folder_1_path=/tmp
#folder_1_careful=2500
#folder_1_warning=3000
#folder_1_critical=3500
#folder_1_refresh=60

[cloud]
disable=True

[raid]
disable=True

[smart]
disable=True

[hddtemp]
disable=True

[sensors]
disable=True

[processcount]
disable=False
# If you want to change the refresh rate of the processing list, please uncomment:
#refresh=10

[processlist]
disable=False
cpu_careful=50
cpu_warning=70
cpu_critical=90
mem_careful=50
mem_warning=70
mem_critical=90
nice_warning=-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
# Define the list of processes to export using:
# a comma-separated list of Glances filter
#export=.*firefox.*,pid:1234

[ports]
disable=False
refresh=30
timeout=3
port_default_gateway=True

[containers]
disable=False
max_name_size=20
all=False
podman_sock=${PODMAN_UNIX}

[influxdb2]
host=influxdb.local.timmybtech.com
port: 443
protocol=https
org=homelab
bucket=glances
token=${INFLUXDB_TOKEN}

[prometheus]
host=localhost
port=9091
#prefix=glances
labels=src:glances,hostname:$(hostname)
EOL
}

create_systemd_service_file() {
    echo_with_color "$GREEN_COLOR" "Creating Glances systemd service file..."
    sudo tee /etc/systemd/system/glances.service >/dev/null <<EOL
[Unit]
Description=Glances Monitoring Service
After=network.target influxd.service

[Service]
WorkingDirectory=${WORKING_DIR}
ExecStart=/home/${USER}/.pyenv/versions/glances/bin/glances --quiet --export influxdb2,prometheus
User=${USER}
Restart=on-failure
RemainAfterExit=yes
RestartSec=30s
TimeoutSec=30s

[Install]
WantedBy=multi-user.target
EOL
}

start_glances_service() {
    echo_with_color "$GREEN_COLOR" "Starting glances service..."
    sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
    sudo systemctl enable --now glances || exit_with_error "Failed to enable and start glances service."
    sudo systemctl status --no-pager glances || exit_with_error "Failed to check glances service status."
    echo_with_color "$GREEN_COLOR" "Glances service started successfully."
}

move_python_version_file(){
    echo_with_color "$GREEN_COLOR" "Moving .python-version file..."
    if [ ! -f "${WORKING_DIR}/.python-version" ]; then
        mv .python-version "$WORKING_DIR/.python-version"
    fi
}

main() {
    create_directories
    create_virtualenv
    install_dependencies
    create_config_file
    create_systemd_service_file
    start_glances_service
    move_python_version_file
}

main
