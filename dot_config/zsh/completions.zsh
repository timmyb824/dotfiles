eval "$(op completion zsh)"; compdef _op op # pkgx
source <(chezmoi completion zsh)

if command -v ngrok &>/dev/null; then
eval "$(ngrok completion)"
fi