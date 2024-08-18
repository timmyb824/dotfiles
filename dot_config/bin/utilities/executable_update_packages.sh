#!/bin/bash

source common.sh

####### VARIABLES #######

PYTHON_VERSION="3.11.0"
RUBY_VERSION="3.2.1"
OS=$(get_os)

######## PACKAGES ########

### HOMEBREW ###
logger "STARTING HOMEBREW"
if command_exists brew; then
  brew update
  if [ $? -ne 0 ]; then
    mgs_error "brew update failed."
    msg_warn "Try running 'brew update' manually after the script completes."
  fi
  msg_ok "'brew update' completed."

  brew upgrade
  if [ $? -ne 0 ]; then
    msg_error "brew upgrade failed."
    msg_warn "Try running 'brew upgrade' manually after the script completes."
  fi
  msg_ok "'brew upgrade' completed."
else
  msg_info "brew is not installed. Skipping brew update and upgrade."
fi

### PKGX ###
logger "STARTING PKGX"
if command_exists pkgx; then
  pkgx mash pkgx/cache upgrade
  if [ $? -ne 0 ]; then
    msg_error "pkgx mash pkgx/cache upgrade failed."
  fi
  msg_ok "'pkgx mash pkgx/cache upgrade' completed."
else
  msg_info "pkgx is not installed. Skipping pkgx mash pkgx/cache upgrade."
fi

### VAGRANT PLUGINS ###
logger "STARTING VAGRANT PLUGINS"
if command_exists vagrant; then
  vagrant plugin update
  if [ $? -ne 0 ]; then
    msg_error "vagrant plugin update failed."
  fi
  msg_ok "Vagrant plugin updates completed."
else
  msg_info "vagrant is not installed. Skipping vagrant plugin update."
fi

### NPM ###
logger "STARTING NPM"
if command_exists npm; then
  npm update -g
  if [ $? -ne 0 ]; then
    msg_error "npm update failed."
  fi
  msg_ok "NPM updates completed."
else
  msg_info "npm is not installed. Skipping npm update."
fi

### PIP ###
logger "STARTING PIP"
if command_exists pip; then
  msg_info "Verifying python version..."
  python_version=$(python --version | awk '{print $2}')
  if [ "$python_version" != "$PYTHON_VERSION" ]; then
    msg_error "Python version $PYTHON_VERSION is required. Found $python_version."
  fi
  msg_info "Python version matches $PYTHON_VERSION."
  msg_info "Updating pip..."
  pip install --upgrade pip
  if [ $? -ne 0 ]; then
    msg_error "pip install --upgrade pip failed."
  fi

  msg_info "Updating pip packages..."
  pip freeze --local | grep -v '^-e' | cut -d = -f 1 | xargs -n1 pip install -U
  if [ $? -ne 0 ]; then
    msg_error "pip install -U failed."
  fi

  msg_ok "pip updates completed."
else
  msg_info "pip is not installed. Skipping pip install --upgrade pip."
fi

### PIPX ###
logger "STARTING PIPX"
if command_exists pipx; then
  pipx upgrade-all
  if [ $? -ne 0 ]; then
    msg_error "pipx upgrade-all failed."
  fi
  msg_ok "pipx updates completed."
else
  msg_ok "pipx is not installed. Skipping pipx upgrade-all."
fi

### Kubectl Krew ###
logger "STARTING KUBECTL KREW"
if command_exists kubectl-krew; then
  kubectl krew update
  if [ $? -ne 0 ]; then
    msg_error "kubectl krew update failed."
  fi

  msg_info "Upgrading kubectl plugins..."
  kubectl krew upgrade
  if [ $? -ne 0 ]; then
    msg_error "kubectl krew upgrade failed."
  fi
  msg_ok "krew updates completed."
else
  msg_info "kubectl is not installed. Skipping kubectl krew update."
fi

### GEMS ###
logger "STARTING GEMS"
if command_exists gem; then
  msg_info "Verifying ruby version..."
  ruby_version=$(ruby --version | awk '{print $2}')
  if [ "$ruby_version" != "$RUBY_VERSION" ]; then
    msg_error "Ruby version $RUBY_VERSION is required. Found $ruby_version."
  fi
  msg_info "Ruby version matches $RUBY_VERSION."
  msg_info "Updating gems..."
  gem update
  if [ $? -ne 0 ]; then
    msg_error "gem update failed."
  fi

  msg_ok "gem updates completed."
else
  msg_info "gem is not installed. Skipping gem update."
fi

### BASHER ###
logger "STARTING BASHER"
if command_exists basher; then
  cd ~/.basher || msg_error "cd to ~/.basher failed."
  git pull
  if [ $? -ne 0 ]; then
    msg_error "git pull in ~/.basher failed."
  fi
  msg_info "Updating basher packages..."
  outdated_packages=$(basher outdated | awk '{print $1}')
  for package in $outdated_packages; do
    basher upgrade "$package"
    if [ $? -ne 0 ]; then
      msg_error "basher upgrade $package failed."
    fi
  done
  msg_ok "basher updates completed."
else
  msg_info "basher is not installed. Skipping basher update."
fi

### GH CLI ###
logger "STARTING GH CLI"
if command_exists gh; then
  gh extension upgrade --all
  if [ $? -ne 0 ]; then
    msg_error "gh extension upgrade --all failed."
  fi
  msg_ok "gh cli updates completed."
else
  msg_info "gh cli is not installed. Skipping gh extension upgrade --all."
fi

### MICRO EDITOR ###
logger "STARTING MICRO EDITOR"
if command_exists micro; then
  micro -plugin update
  if [ $? -ne 0 ]; then
    msg_error "micro -plugin update failed."
  fi
  msg_ok "micro editor plugin updates completed."
else
  msg_info "micro is not installed. Skipping micro -plugin update."
fi

### APT-GET UPDATE ###
logger "STARTING APT-GET UPDATE"
if command_exists apt-get; then
  sudo apt-get update
  if [ $? -ne 0 ]; then
    msg_error "apt-get update failed."
  fi
  msg_ok "apt-get updates completed."
else
  msg_info "apt-get is not installed. Skipping apt-get update."
fi

### APT-GET UPGRADE ###
logger "STARTING APT-GET UPGRADE"
if command_exists apt-get; then
  sudo apt-get upgrade -y
  if [ $? -ne 0 ]; then
    msg_error "apt-get upgrade failed."
  fi
  msk_ok "apt-get upgrade completed."
else
  msg_info "apt-get is not installed. Skipping apt-get upgrade."
fi

### GO INSTALL ###
logger "STARTING GO INSTALL"
if [[ "$OS" == "Linux" ]]; then
  if command_exists go; then
    bash "$HOME/.config/bin/package-managers/go.sh"
    if [ $? -ne 0 ]; then
      msg_error "go install failed."
    fi
    msg_ok "go updates completed."
  else
    msg_info "go is not installed. Skipping go install."
  fi
else
  msg_info "Skipping go install on macOS."
fi

### RUST ###
logger "STARTING RUST"
if [[ "$OS" == "Linux" ]]; then
  if command_exists rustup; then
    msg_info "Updating rust..."
    rustup update
    if [ $? -ne 0 ]; then
      msg_error "rustup update failed."
    fi
    msg_ok "rust updates completed."

    msg_info "Updating cargo packages..."
    while IFS= read -r package; do
      trimmed_package=$(echo "$package" | xargs)
      if [ -n "$trimmed_package" ]; then
        output=$(cargo install "$trimmed_package" --force)
        echo "$output"
        if [[ "$output" == *"error"* ]]; then
          msg_error "Failed to update ${trimmed_package}."
          msg_warn "Continuing with the next package..."
        else
          msg_ok "${trimmed_package} updated successfully."
        fi
      fi
    done < <(get_package_list cargo_linux.list)
  else
    msg_info "rust is not installed. Skipping rust update."
  fi
else
  msg_info "Skipping rust update on macOS."
fi

logger "UPDATE PACKAGES SCRIPT COMPLETED!"
