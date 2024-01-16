#!/Users/timothybryant/.local/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

OS=$(get_os)
# Check if the OS is Linux
if [ "$OS" != "Linux" ]; then
    echo_with_color "34" "This script is intended only for Linux. Exiting without running."
    exit 0
fi

# Prompt for variables
read -p "Enter the username for the local system: " LOCAL_USER
read -p "Enter the username for the remote SSH user: " SSH_REMOTE_USER
read -p "Enter the public SSH key contents: " SSH_KEY_CONTENTS
read -s -p "Enter the user's password: " SSH_PASSWORD
echo ""
read -p "Enter a salt for the password encryption: " SALT
echo ""

# Function to check if a user exists
user_exists() {
    if id "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create a user with the given parameters
create_user() {
    local username=$1
    local password=$2
    local salt=$3
    local enc_password

    # Encrypt the password using openssl with the provided salt
    enc_password=$(openssl passwd -6 -salt "$salt" "$password")

    if user_exists "$username"; then
        echo "User $username already exists"
    else
        sudo useradd -m -s /bin/bash -p "$enc_password" -G sudo "$username"
        echo "User $username created and added to sudo group"
    fi
}

# Function to add a public SSH key to the authorized_keys of the user
add_ssh_key() {
    local username=$1
    local key=$2
    local ssh_dir="/home/$username/.ssh"

    if [ ! -d "$ssh_dir" ]; then
        sudo mkdir "$ssh_dir"
        sudo chown "$username":"$username" "$ssh_dir"
        sudo chmod 700 "$ssh_dir"
    fi

    echo "$key" | sudo tee -a "$ssh_dir/authorized_keys" > /dev/null
    sudo chown "$username":"$username" "$ssh_dir/authorized_keys"
    sudo chmod 600 "$ssh_dir/authorized_keys"
    echo "Public SSH key added to $username's authorized_keys"
}

# Function to create a sudoers file for the user if it doesn't exist
create_sudoers_file() {
    local username=$1
    local file="/etc/sudoers.d/$username"
    if [ ! -f "$file" ]; then
        echo "$username ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo -f "$file"
        sudo chmod 0440 "$file"
        echo "Sudoers file for $username created"
    else
        echo "Sudoers file for $username already exists"
    fi
}

# Create a login user and add public key
for username in $LOCAL_USER $SSH_REMOTE_USER; do
    if [ -n "$username" ]; then
        create_user "$username" "$SSH_PASSWORD" "$SALT"
        add_ssh_key "$username" "$SSH_KEY_CONTENTS"

        if [ "$username" = "$SSH_REMOTE_USER" ]; then
            create_sudoers_file "$username"
        fi
    fi
done