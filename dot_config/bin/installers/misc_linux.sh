#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_local_send() {
    local_send_version="1.14.0"
    local_send_deb="LocalSend-${local_send_version}-linux-x86-64.deb"
    local_send_url="https://github.com/localsend/localsend/releases/download/v${local_send_version}/${local_send_deb}"
    if ! command_exists "localsend"; then
        echo_with_color "$YELLOW_COLOR" "LocalSend is not installed."
        ask_yes_or_no "Do you want to install local_send?"
        if [[ "$?" -eq 0 ]]; then
            if ! curl -sS "$local_send_url" -o "$local_send_deb"; then
                echo_with_color "$RED_COLOR" "Failed to download LocalSend."
            else
                sudo dpkg -i "$local_send_deb"
                rm "$local_send_deb"
                echo_with_color "$GREEN_COLOR" "LocalSend installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping LocalSend installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "LocalSend is already installed."
    fi
}

install_plandex_cli() {
    if ! command_exists "plandex"; then
        echo_with_color "$YELLOW_COLOR" "plandex-cli is not installed."
        ask_yes_or_no "Do you want to install plandex-cli?"
        if [[ "$?" -eq 0 ]]; then
            if ! curl -sS https://plandex.ai/install.sh | bash; then
                echo_with_color "$RED_COLOR" "Failed to install plandex-cli."
            else
                echo_with_color "$GREEN_COLOR" "plandex-cli installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping plandex-cli installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "plandex-cli is already installed."
    fi
}

istall_helix_edtor() {
    if ! command_exists "hx"; then
        echo_with_color "$YELLOW_COLOR" "Helix editor is not installed."
        ask_yes_or_no "Do you want to install Helix editor?"
        if [[ "$?" -eq 0 ]]; then
            echo_with_color "$YELLOW_COLOR" "Installing Helix editor."
            sudo add-apt-repository ppa:maveonair/helix-editor -y || echo_with_color "$RED_COLOR" "Failed to add Helix editor repository."
            sudo apt update || echo_with_color "$RED_COLOR" "Failed to update apt."
            sudo apt install helix -y || echo_with_color "$RED_COLOR" "Failed to install Helix editor."
        else
            echo_with_color "$GREEN_COLOR" "Skipping Helix editor installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "Helix editor is already installed."
    fi
}

install_supafile() {
    if ! command_exists "spf"; then
        echo_with_color "$YELLOW_COLOR" "supafile is not installed."
        ask_yes_or_no "Do you want to install supafile?"
        if [[ "$?" -eq 0 ]]; then
            if ! bash -c "$(wget -qO- https://superfile.netlify.app/install.sh)"; then
                echo_with_color "$RED_COLOR" "Failed to install supafile."
            else
                echo_with_color "$GREEN_COLOR" "supafile installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping supafile installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "supafile is already installed."
    fi
}

install_oci_cli() {
  if ! command_exists oci; then
    echo_with_color "$YELLOW_COLOR" "Oracle Cloud Infrastructure CLI is not installed."
    ask_yes_or_no "Do you want to install Oracle Cloud Infrastructure CLI?"
    if [[ "$?" -eq 0 ]]; then
      if ! bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"; then
      echo_with_color "$RED_COLOR" "Failed to install Oracle Cloud Infrastructure CLI."
      else
      echo_with_color "$GREEN_COLOR" "Oracle Cloud Infrastructure CLI installed successfully."
      fi
    else
      echo_with_color "$GREEN_COLOR" "Skipping Oracle Cloud Infrastructure CLI installation."
    fi
      else
    echo_with_color "$GREEN_COLOR" "Oracle Cloud Infrastructure CLI is already installed."
      fi
}

install_cloudflared_cli() {
    if ! command_exists cloudflared; then
        echo_with_color "$YELLOW_COLOR" "Cloudflared CLI is not installed."
        ask_yes_or_no "Do you want to install Cloudflared CLI?"
        if [[ "$?" -eq 0 ]]; then
            sudo mkdir -p --mode=0755 /usr/share/keyrings/ || echo_with_color "$RED_COLOR" "Failed to create keyrings directory."
            if ! curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null; then
                echo_with_color "$RED_COLOR" "Failed to download Cloudflared CLI key."
            else
                echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
                sudo apt-get update || echo_with_color "$RED_COLOR" "Failed to update apt."
                sudo apt-get install cloudflared -y || echo_with_color "$RED_COLOR" "Failed to install Cloudflared CLI."
                echo_with_color "$GREEN_COLOR" "Cloudflared CLI installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping Cloudflared CLI installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "Cloudflared CLI is already installed."
    fi
}

install_logdy() {
    local logdy_version="0.12.0"
    if ! command_exists logdy; then
        echo_with_color "$YELLOW_COLOR" "Logdy is not installed."
        ask_yes_or_no "Do you want to install Logdy?"
        if [[ "$?" -eq 0 ]]; then
            if ! sudo wget https://github.com/logdyhq/logdy-core/releases/download/v${logdy_version}/logdy_linux_amd64 -O /usr/local/bin/logdy; then
                echo_with_color "$RED_COLOR" "Failed to download Logdy."
            else
                sudo chmod +x /usr/local/bin/logdy
                echo_with_color "$GREEN_COLOR" "Logdy installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping Logdy installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "Logdy is already installed."
    fi
}


install_fastfetch(){
    local fastfetch_version="2.23.0"
    local fastfetch_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${fastfetch_version}/fastfetch-linux-amd64.tar.gz"
    
    if ! command_exists fastfetch; then
        echo_with_color "$YELLOW_COLOR" "fastfetch is not installed."
        ask_yes_or_no "Do you want to install fastfetch?"
        
        if [[ "$?" -eq 0 ]]; then
            if ! curl -L -sS "$fastfetch_url" -o fastfetch.tar.gz; then
                echo_with_color "$RED_COLOR" "Failed to download fastfetch."
            else
                echo_with_color "$GREEN_COLOR" "Installing fastfetch..."
                tar -xzf fastfetch.tar.gz
                sudo mv fastfetch-linux-amd64/usr/bin/fastfetch /usr/local/bin
                sudo mv fastfetch-linux-amd64/usr/bin/flashfetch /usr/local/bin                              
                rm fastfetch-linux-amd64
                echo_with_color "$GREEN_COLOR" "fastfetch installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping fastfetch installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "fastfetch is already installed."
    fi
}

# check for dependencies
if ! command_exists "curl" && ! command_exists "wget"; then
    echo_with_color "$RED_COLOR" "curl/wget is required"
fi

install_local_send
install_plandex_cli
istall_helix_edtor
install_supafile
install_oci_cli
install_cloudflared_cli
install_logdy
install_fastfetch

