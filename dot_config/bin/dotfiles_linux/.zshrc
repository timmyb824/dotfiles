# Source initialization settings
source "$HOME/.config/zsh/init.zsh"

# Source the alias file
precmd() {
    source "$HOME/.config/zsh/alias.zsh"
}

# Source the plugin manager
source "$HOME/.config/zsh/plugin_manager.zsh"

# Source the functions file
source "$HOME/.config/zsh/functions.zsh"

# Set environment variables
source "$HOME/.config/zsh/env.zsh"

# Setup completions
source "$HOME/.config/zsh/completions.zsh"

# Load plugins and package managers
source "$HOME/.config/zsh/packages.zsh"
