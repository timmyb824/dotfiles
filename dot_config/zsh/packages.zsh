eval "$(pyenv init --path)"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

eval "$(basher init - zsh)"
eval "$(kickstart infect)" # basher
eval "$(zoxide init zsh)" # pkgx
eval "$(direnv hook zsh)" # pkgx
eval "$(fnm env --use-on-cd)" # pkgx
eval "$(rbenv init - zsh)" # homebrew
# eval "$(register-python-argcomplete pipx)" # pkgx
source /Users/timothybryant/.config/broot/launcher/bash/br # pkgx

#if command -v termium > /dev/null 2>&1; then
#  eval "$(termium shell-hook show post)"
#fi