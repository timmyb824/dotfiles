#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Turn off natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

