# Initialization settings
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$HOME/.zsh/completion:$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}:' # uncomment for debugging (run `set -x` to enable)

autoload -Uz compinit && compinit

# initialize shell integration
source <(pkgx --shellcode)  #docs.pkgx.sh/shellcode
export PATH="$HOME/.local/bin:$PATH"

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    source <(starship init zsh --print-full-init)
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
    eval "$(atuin init zsh)"
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi