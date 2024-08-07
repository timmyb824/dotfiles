#!/bin/bash

source ./common.sh

# confirm an argument is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <add|remove>"
  exit 1
fi

# if arg is `add` then prepend 1.1.1.1 to top of resolv.conf
if [ "$1" == "add" ]; then
  msg_info "Adding 1.1.1.1 to resolv.conf..."
  # Create a temporary file with the new nameserver at the top
  sudo sed -i '1inameserver 1.1.1.1' /etc/resolv.conf
  msg_ok "Done"
fi

# if arg is `remove` then remove 1.1.1.1 from resolv.conf
if [ "$1" == "remove" ]; then
  msg_info "Removing 1.1.1.1 from resolv.conf..."
  sudo sed -i '/^nameserver 1.1.1.1$/d' /etc/resolv.conf
  msg_ok "Done"
fi
