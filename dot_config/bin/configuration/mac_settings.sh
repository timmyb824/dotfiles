#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"
# install rosetta
if [[ ! -d "/Library/Apple/System/Library/LaunchDaemons" ]]; then
  echo "Rosetta is not installed. Installing Rosetta..."
  softwareupdate --install-rosetta --agree-to-license
  echo "Rosetta installation complete."
else
  echo "Rosetta is already installed."
fi

# Turn off natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

