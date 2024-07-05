#!/bin/bash

####### VARIABLES #######

PYTHON_VERSION="3.11.0"
RUBY_VERSION="3.2.1"

######## FUNCTIONS ########

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
  echo "----------------------------------------"
}

# Function to handle errors
handle_error() {
  log "Error: $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

######## PACKAGES ########

### HOMEBREW ###
if command_exists brew; then
  # Run brew update
  log "Running 'brew update'..."
  brew update
  if [ $? -ne 0 ]; then
    handle_error "brew update failed."
    log "Try running 'brew update' manually after the script completes."
  fi
  log "'brew update' completed."

  # Run brew upgrade
  log "Running 'brew upgrade'..."
  brew upgrade
  if [ $? -ne 0 ]; then
    handle_error "brew upgrade failed."
    log "Try running 'brew upgrade' manually after the script completes."
  fi
  log "'brew upgrade' completed."
else
  log "brew is not installed. Skipping brew update and upgrade."
fi

### PKGX ###
if command_exists pkgx; then
  # Run pkgx mash pkgx/cache upgrade
  log "Running 'pkgx mash pkgx/cache upgrade'..."
  pkgx mash pkgx/cache upgrade
  if [ $? -ne 0 ]; then
    handle_error "pkgx mash pkgx/cache upgrade failed."
  fi
  log "'pkgx mash pkgx/cache upgrade' completed."
else
  log "pkgx is not installed. Skipping pkgx mash pkgx/cache upgrade."
fi

### VAGRANT PLUGINS ###
if command_exists vagrant; then
  log "Updating vagrant plugins..."
  vagrant plugin update
  if [ $? -ne 0 ]; then
    handle_error "vagrant plugin update failed."
  fi

  log "Vagrant plugin updates completed."
else
  log "vagrant is not installed. Skipping vagrant plugin update."
fi

### NPM ###
if command_exists npm; then
  log "Updating npm packages..."
  npm update -g
  if [ $? -ne 0 ]; then
    handle_error "npm update failed."
  fi

  log "NPM updates completed."
else
  log "npm is not installed. Skipping npm update."
fi

### PIP ###
if command_exists pip; then
  # verify python version
  log "Verifying python version..."
  python_version=$(python --version | awk '{print $2}')
  if [ "$python_version" != "$PYTHON_VERSION" ]; then
    handle_error "Python version $PYTHON_VERSION is required. Found $python_version."
  fi
  log "Python version matches $PYTHON_VERSION."
  log "Updating pip..."
  pip install --upgrade pip
  if [ $? -ne 0 ]; then
    handle_error "pip install --upgrade pip failed."
  fi

  log "Updating pip packages..."
  pip freeze --local | grep -v '^-e' | cut -d = -f 1 | xargs -n1 pip install -U
  if [ $? -ne 0 ]; then
    handle_error "pip install -U failed."
  fi

  log "pip updates completed."
else
  log "pip is not installed. Skipping pip install --upgrade pip."
fi

### PIPX ###
if command_exists pipx; then
  log "Updating pipx packages..."
  pipx upgrade-all
  if [ $? -ne 0 ]; then
    handle_error "pipx upgrade-all failed."
  fi

  log "pipx updates completed."
else
  log "pipx is not installed. Skipping pipx upgrade-all."
fi

### Kubectl Krew ###
if command_exists kubectl-krew; then
  log "Updating kubectl plugin index..."
  kubectl krew update
  if [ $? -ne 0 ]; then
    handle_error "kubectl krew update failed."
  fi

  log "Upgrading kubectl plugins..."
  kubectl krew upgrade
  if [ $? -ne 0 ]; then
    handle_error "kubectl krew upgrade failed."
  fi

  log "krew updates completed."
else
  log "kubectl is not installed. Skipping kubectl krew update."
fi

### Gems ###
if command_exists gem; then
  # verify ruby version
  log "Verifying ruby version..."
  ruby_version=$(ruby --version | awk '{print $2}')
  if [ "$ruby_version" != "$RUBY_VERSION" ]; then
    handle_error "Ruby version $RUBY_VERSION is required. Found $ruby_version."
  fi
  log "Ruby version matches $RUBY_VERSION."
  log "Updating gems..."
  gem update
  if [ $? -ne 0 ]; then
    handle_error "gem update failed."
  fi

  log "gem updates completed."
else
  log "gem is not installed. Skipping gem update."
fi

### Basher ###
if command_exists basher; then
  log "Updating basher..."
  cd ~/.basher || handle_error "cd to ~/.basher failed."
  git pull
  if [ $? -ne 0 ]; then
    handle_error "git pull in ~/.basher failed."
  fi
  log "Updating basher packages..."
  outdated_packages=$(basher outdated | awk '{print $1}')
  for package in $outdated_packages; do
    basher upgrade "$package"
    if [ $? -ne 0 ]; then
      handle_error "basher upgrade $package failed."
    fi
  done
  log "basher updates completed."
else
  log "basher is not installed. Skipping basher update."
fi

### gh cli ###
if command_exists gh; then
  log "Updating gh cli..."
  gh extension upgrade --all
  if [ $? -ne 0 ]; then
    handle_error "gh extension upgrade --all failed."
  fi
  log "gh cli updates completed."
else
  log "gh cli is not installed. Skipping gh extension upgrade --all."
fi

### micro editor ###
if command_exists micro; then
  log "Updating micro editor plugins..."
  micro -plugin update
  if [ $? -ne 0 ]; then
    handle_error "micro -plugin update failed."
  fi
  log "micro editor plugin updates completed."
else
  log "micro is not installed. Skipping micro -plugin update."
fi


log "UPDATE PACKAGES SCRIPT COMPLETED!"