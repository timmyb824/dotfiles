################### PERSONAL CONFIGUARTION ##################
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    source <($HOME/.local/bin/starship init zsh --print-full-init) #pkgx
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
    eval "$(atuin init zsh)" # homebrew
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}:' # uncomment for debugging (run `set -x` to enable)

autoload -Uz compinit && compinit

source <(pkgx --shellcode)  #docs.pkgx.sh/shellcode
precmd() {
    source "$HOME/.config/zsh/alias.zsh"
}
source "$HOME/.config/zsh/plugin_manager.zsh"
source "$HOME/.config/zsh/functions.zsh"
source /Users/timothybryant/.config/broot/launcher/bash/br # pkgx

eval "$(zoxide init zsh)" # pkgx
eval "$(direnv hook zsh)" # pkgx
eval "$(fnm env --use-on-cd)" # pkgx
eval "$(rbenv init - zsh)" # homebrew

export SOPS_AGE_KEY_FILE=$HOME/.sops/age-master-key.txt
export EDITOR="micro" # pkgx
export HOMEBREW_NO_ANALYTICS=1
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export VIRTUAL_ENV_DISABLE_PROMPT=1 # stop issue where virtualenv was erroneously appearing at the end of every cmd output
export PATH=$PATH:$HOME/.local/bin/go # pkgx
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/go/bin/
export MICRO_TRUECOLOR=1
export VAULT_ADDR="https://vault.local.timmybtech.com"
export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.basher/bin:$PATH" # source (git)
eval "$(basher init - zsh)"
eval "$(kickstart infect)" # basher

export PYENV_ROOT="$HOME/.pyenv" # homebrew
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
