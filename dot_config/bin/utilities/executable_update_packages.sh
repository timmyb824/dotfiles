#!/bin/bash


######## FUNCTIONS ########

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
  echo "----------------------------------------"
}

# Function to handle errors
handle_error() {
  log "Error: $1"
  exit 1
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
  fi
  log "'brew update' completed successfully."

  # Run brew upgrade
  log "Running 'brew upgrade'..."
  brew upgrade
  if [ $? -ne 0 ]; then
    handle_error "brew upgrade failed."
  fi
  log "'brew upgrade' completed successfully."
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
  log "'pkgx mash pkgx/cache upgrade' completed successfully."
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

  log "All updates completed successfully."
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

  log "All updates completed successfully."
else
  log "npm is not installed. Skipping npm update."
fi

### PIPX ###
if command_exists pipx; then
  log "Updating pipx packages..."
  pipx upgrade-all
  if [ $? -ne 0 ]; then
    handle_error "pipx upgrade-all failed."
  fi

  log "All updates completed successfully."
else
  log "pipx is not installed. Skipping pipx upgrade-all."
fi