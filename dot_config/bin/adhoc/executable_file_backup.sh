#!/usr/bin/env bash


##### THIS IS A WORK IN PROGRESS #####

source "$(dirname "${BASH_SOURCE[0]}")/../init/init.sh"
# Function to print usage
usage() {
    echo "Usage: $0 <local_path> <nas_path>"
    echo "Example: $0 /path/to/local/file /volume1/homelab/backup"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

LOCAL_PATH=$1
NAS_PATH=$2

MOUNT_POINT="/mnt/bryantnas"
NAS_IP="192.168.86.44"
NAS_USER="tab802"
NAS_PORT=717

# Check if the local path exists
if [ ! -e "$LOCAL_PATH" ]; then
    exit_with_error "The local path $LOCAL_PATH does not exist."
fi

# Check if the mount point is present and the destination folder exists there
if [ -d "$MOUNT_POINT" ]; then
    if [ -e "$MOUNT_POINT$NAS_PATH" ]; then
        echo_with_color "\033[0;32m" "The destination $MOUNT_POINT$NAS_PATH already exists. No need to perform rsync."
        exit 0
    fi
else
    # If the mount point is not present, perform rsync over the network
    echo_with_color "\033[0;34m" "Mount point $MOUNT_POINT not found. Using rsync over the network..."
    if ! rsync -avz -e "ssh -p $NAS_PORT" "$LOCAL_PATH" "$NAS_USER@$NAS_IP:$NAS_PATH"; then
        exit_with_error "Failed to perform rsync."
    fi
    echo_with_color "\033[0;32m" "Successfully synced $LOCAL_PATH to $NAS_USER@$NAS_IP:$NAS_PATH."
fi