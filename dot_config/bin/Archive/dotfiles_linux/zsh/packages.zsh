eval "$(pyenv init --path)"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

eval "$(zoxide init zsh)" # pkgx
eval "$(direnv hook zsh)" # pkgx
eval "$(fnm env --use-on-cd)" # pkgx
eval "$(basher init - zsh)"
eval "$(kickstart infect)" # basher
eval "$(rbenv init - zsh)"

source "$HOME/.config/broot/launcher/bash/br" # pkgx
