##############################################################################
#                                                                            #
#                             PLUGIN MANAGER                                 #
#                                                                            #
#         Inspired by: https://github.com/mattmc3/zsh_unplugged              #
#    Find plugins at: https://github.com/unixorn/awesome-zsh-plugins#plugins #
#                          Created by: Timothy Bryant                        #
#                                                                            #
##############################################################################

# Check for dependencies
if ! command -v git &> /dev/null
then
    echo "git could not be found"
    exit
fi

if ! command -v zsh &> /dev/null
then
    echo "zsh could not be found"
    exit
fi

# Global variable for Zsh plugins directory
ZPLUGINDIR=${ZDOTDIR:-$HOME}/.config/zsh/plugins


# Function to clone a plugin, identify its init file, source it, and add it to your fpath.
function plugin-load {
  local repo plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-$HOME}/.config/zsh/plugins}
  for repo in "$@"; do
    plugdir="$ZPLUGINDIR/${repo##*/}"
    initfile="$plugdir/${repo##*/}.plugin.zsh"
    if [[ ! -d "$plugdir" ]]; then
      echo "Cloning $repo..."
      if ! git clone -q --depth 1 --recursive --shallow-submodules \
        "https://github.com/$repo" "$plugdir"; then
        echo "Failed to clone $repo"
        continue
      fi
    fi
    if [[ ! -e "$initfile" ]]; then
      initfiles=("$plugdir"/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( ${#initfiles[@]} )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf "${initfiles[1]}" "$initfile"
    fi
    fpath+="$plugdir"
    (( $+functions[zsh-defer] )) && zsh-defer . "$initfile" || . "$initfile"
  done
}

# List of github repo plugins
plugins=(
  timmyb824/zsh-pins # my own fork of mehalter/zsh-pins
  mdumitru/git-aliases
  agpenton/1password-zsh-plugin
  sparsick/ansible-zsh
  Tarrasch/zsh-bd
  ChrisPenner/copy-pasta
  reegnz/jq-zsh-plugin
  Matt561/zsh-nhl-schedule
  amstrad/oh-my-matrix
  MichaelAquilina/zsh-you-should-use
  supercrabtree/k
  # zsh-users/zsh-syntax-highlighting

  # speed things up by loading intensive plugins after zsh-defer
  romkatv/zsh-defer
)

# List of github repo plugins not to load on Warp terminal
warp_exclusive_plugins=(
  Aloxaf/fzf-tab
  zdharma/fast-syntax-highlighting
  clarketm/zsh-completions
  zsh-users/zsh-autosuggestions
)

# If not running on Warp terminal, load the additional plugins
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  plugins=("${plugins[@]}" "${warp_exclusive_plugins[@]}")
fi

plugin-load "${plugins[@]}"

# Function to update all plugins
function plugin-update {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in "$ZPLUGINDIR"/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

# Function to remove all plugins
function plugin-remove {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in "$ZPLUGINDIR"/*/.git(/); do
    echo "Removing ${d:h:t}..."
    rm -rf "${d:h}"
  done
}

# Function to remove a specific plugin by name  - part after the last slash
function plugin-remove-by-name {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in "$ZPLUGINDIR"/*/.git(/); do
    if [[ "${d:h:t}" == "$1" ]]; then
      echo "Removing ${d:h:t}..."
      rm -rf "${d:h}"
    fi
  done
}

# Function to list all plugins
function plugin-list {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in "$ZPLUGINDIR"/*/.git(/); do
    echo "${d:h:t}"
  done
}
