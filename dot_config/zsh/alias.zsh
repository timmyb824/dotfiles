
alias _=sudo
alias awsp="source _awsp"
alias awsprofile="source _awsp"
alias bash='~/.local/bin/bash'
alias btm="btm --color gruvbox"
alias cat="bat"
alias cd..="cd .."
alias cdicloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs"
alias chez="chezmoi"
# alias dbuild="docker-compose up -d --force-recreate --build"
# alias dclogs="docker-compose logs -f"
# alias dcup="docker-compose up -d --force-recreate"
# alias ddown="docker-compose down"
# alias dockerports="docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.State}}\t{{.RunningFor}}""
# alias dockerps="docker ps --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Networks}}\t{{.State}}\t{{.RunningFor}}""
alias find="~/.local/bin/find"
alias fdn='find . -type d -name' # fd is a seperate command
alias ff="find . -type f -name"
alias git="~/.local/bin/git"
alias gop="gitopolis"
alias g=git
# alias k9s="k9s --kubeconfig ~/.kube/config_k3s "
alias kk=kubectl
alias kns='kubectl ns' # installed with krew
alias kcx='kubectl ctx' # installed with krew
alias la="lsd -lAh"
alias ldot="lsd -ld .*"
alias lg="lazygit"
alias ls="lsd"
alias ll="lsd -lh"
alias nano="/opt/homebrew/bin/nano"
alias oc="opencommit"
alias po=podman
alias poc='podman compose'
alias please=sudo
alias pr="poetry run"
alias px=pkgx
alias pxi="pkgx install"
alias quit=exit
alias reload="source ~/.zshrc"
alias sopse="sops --encrypt --age $AGE_PUBLIC_KEY -i "
alias sopds="sops --decrypt --age $AGE_PUBLIC_KEY -i "
alias sshadd="ssh-add ~/.ssh/id_master_key"
alias sshstart="eval `ssh-agent -s`"
alias tf=terraform
alias wtf=wtfutil
alias zbench="for i in {1..10}; do /usr/bin/time zsh -lic exit; done"
alias zshconfig="nano ~/.zshrc"
