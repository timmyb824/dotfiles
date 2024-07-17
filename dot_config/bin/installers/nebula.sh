#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

create_ca_key_crt() {
  if [ ! -f "$HOME/ca.key" ] || [ ! -f "$HOME/ca.crt" ]; then
    echo_with_color "$GREEN_COLOR" "Creating Certificate Authority..."
    nebula-cert ca -name "BryantHomelab"
    mv ca.key "$HOME"
    mv ca.crt "$HOME"
  fi
}

download_and_extract_nebula() {
  echo_with_color "$GREEN_COLOR" "Downloading Nebula..."
  curl -sLO https://github.com/slackhq/nebula/releases/download/v1.9.3/nebula-linux-amd64.tar.gz
  tar -xzf nebula-linux-amd64.tar.gz -C /tmp
  sudo mv /tmp/nebula /usr/local/bin/
  sudo mv /tmp/nebula-cert /usr/local/bin/
  rm nebula-linux-amd64.tar.gz
}

setup_lighthouse() {
  echo_with_color "$GREEN_COLOR" "Setting up Lighthouse..."
  read -r -p "Enter the name for the Lighthouse (e.g., lighthouse1): " LH_NAME
  read -r -p "Enter the nebula IP address for the Lighthouse (e.g., 192.168.100.1/24): " LH_IP
  read -r -p "Enter the public IP/DNS address for the Lighthouse server: " LH_ROUTABLE_IP

  create_ca_key_crt

  nebula-cert sign -name "${LH_NAME}" -ip "${LH_IP}" -ca-key "$HOME/ca.key" -ca-crt "$HOME/ca.crt"
  if [ ! -f "${LH_NAME}.crt" ] || [ ! -f "${LH_NAME}.key" ]; then
    exit_with_error "Failed to create certificate files for ${LH_NAME}"
  fi
  sudo mkdir -p /etc/nebula

  create_lighthouse_config

  sudo mv "${LH_NAME}".crt /etc/nebula/host.crt
  sudo mv "${LH_NAME}".key /etc/nebula/host.key
  sudo mv "$HOME/ca.crt" /etc/nebula/

  create_systemd_service_file
  create_nebula_user
  start_nebula_service
}

create_lighthouse_config() {
  echo_with_color "$GREEN_COLOR" "Creating Lighthouse config file..."
  sudo tee /etc/nebula/config.yaml >/dev/null <<EOL
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/host.crt
  key: /etc/nebula/host.key

static_host_map:

lighthouse:
  am_lighthouse: true

listen:
  host: 0.0.0.0
  port: 4242

punchy:
  punch: true

logging:
  level: info
  format: text

firewall:
  conntrack:
    tcp_timeout: 12m
    udp_timeout: 3m
    default_timeout: 10m

  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    - port: any
      proto: any
      host: any
EOL
}

setup_host() {
  if [ ! -f "$HOME/ca.key" ] || [ ! -f "$HOME/ca.crt" ]; then
    exit_with_error "Certificate Authority key and certificate not found. Please setup Lighthouse or copy the CA files"
  fi

  echo "Setting up Host..."
  read -r -p "Enter the name for the Host (e.g., server): " HOST_NAME
  read -r -p "Enter the nebula IP address for the Host (e.g., 192.168.100.9/24): " HOST_IP
  read -r -p "Enter the public IP/DNS address for the Lighthouse: " LH_ROUTABLE_IP
  read -r -p "Enter the nebula IP address for the Lighthouse: " LH_IP

  nebula-cert sign -name "${HOST_NAME}" -ip "${HOST_IP}" -ca-key "$HOME/ca.key" -ca-crt "$HOME/ca.crt"
  if [ ! -f "${HOST_NAME}.crt" ] || [ ! -f "${HOST_NAME}.key" ]; then
    exit_with_error "Failed to create certificate files for ${HOST_NAME}"
  fi
  sudo mkdir -p /etc/nebula

  create_host_config

  sudo mv "${HOST_NAME}".crt /etc/nebula/host.crt
  sudo mv "${HOST_NAME}".key /etc/nebula/host.key
  sudo mv "$HOME/ca.crt" /etc/nebula/

  create_systemd_service_file
  create_nebula_user
  start_nebula_service
}

create_host_config() {
  echo_with_color "$GREEN_COLOR" "Creating Host config file..."
  sudo tee /etc/nebula/config.yaml >/dev/null <<EOL
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/host.crt
  key: /etc/nebula/host.key

static_host_map:
  "${LH_IP}": ["${LH_ROUTABLE_IP}:4242"]

lighthouse:
  am_lighthouse: false
  interval: 60
  hosts:
    - "${LH_IP}"

listen:
  host: 0.0.0.0
  port: 4242

punchy:
  punch: true

logging:
  level: info
  format: text

firewall:
  conntrack:
    tcp_timeout: 12m
    udp_timeout: 3m
    default_timeout: 10m

  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    - port: any
      proto: any
      host: any
EOL
}

create_systemd_service_file() {
    echo_with_color "$GREEN_COLOR" "Creating Nebula systemd service file..."
    sudo tee /etc/systemd/system/nebula.service >/dev/null <<EOL
[Unit]
Description=Nebula
Wants=basic.target
After=basic.target network.target
Before=sshd.service

[Service]
ExecStartPre=/usr/local/bin/nebula -test -config /etc/nebula/config.yaml
ExecStart=/usr/local/bin/nebula -config /etc/nebula/config.yaml
ExecReload=/bin/kill -HUP $MAINPID

RuntimeDirectory=nebula
ConfigurationDirectory=nebula
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ProtectControlGroups=true
ProtectHome=true
ProtectKernelTunables=true
ProtectSystem=full
User=nebula
Group=nebula

SyslogIdentifier=nebula

Restart=always
RestartSec=2
TimeoutStopSec=5
StartLimitInterval=0
LimitNOFILE=131072

Nice=-1

[Install]
WantedBy=multi-user.target
EOL
}

create_nebula_user() {
  echo_with_color "$GREEN_COLOR" "Creating Nebula user..."
  sudo useradd -r -s /bin/false nebula
  if [ ! -f /etc/sudoers.d/nebula ]; then
      echo "nebula ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo -f /etc/sudoers.d/nebula >/dev/null
      sudo chmod 0440 /etc/sudoers.d/nebula
      sudo chown -R nebula:nebula /etc/nebula
      echo_with_color "$GREEN_COLOR" "Sudoers file for nebula created"
  else
      echo_with_color "$GREEN_COLOR" "Sudoers file for nebula already exists"
  fi
}


start_nebula_service() {
    echo_with_color "$GREEN_COLOR" "Starting nebula service..."
    sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
    sudo systemctl enable --now nebula || exit_with_error "Failed to enable and start nebula service."
    sudo systemctl status --no-pager nebula || exit_with_error "Failed to check nebula service status."
    echo_with_color "$GREEN_COLOR" "nebula service started successfully."
}

main() {
  if ! command_exists curl; then
    exit_with_error "curl is required to download Nebula. Please install curl and run the script again."
  fi

  echo "Nebula Overlay Network Setup Script"
  echo "==================================="
  echo "1. Setup Lighthouse"
  echo "2. Setup Host"
  read -r -p "Choose an option (1 or 2): " option

  download_and_extract_nebula

  case $option in
    1) setup_lighthouse ;;
    2) setup_host ;;
    *) echo "Invalid option. Please run the script again and choose a valid option." ;;
  esac
}

main "$@"