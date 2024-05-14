#!/bin/bash

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to handle errors
handle_error() {
  log "Error: $1"
  exit 1
}

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

# Run pkgx mash pkgx/cache upgrade
log "Running 'pkgx mash pkgx/cache upgrade'..."
pkgx mash pkgx/cache upgrade
if [ $? -ne 0 ]; then
  handle_error "pkgx mash pkgx/cache upgrade failed."
fi
log "'pkgx mash pkgx/cache upgrade' completed successfully."

log "All updates completed successfully."

