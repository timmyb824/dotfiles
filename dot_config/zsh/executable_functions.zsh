# list non-symlinked and non-ignored executables in .local/bin
list_local_bin() {
    echo "Listing all non-symlinked executables in ~/.local/bin"

    # Define the list of executables to ignore
    ignore_list="code podman-compose awashcli helix-gpt uv uvx"

    # Prepare the grep command to ignore the executables
    ignore_grep=$(echo "$ignore_list" | tr ' ' '|')

    if [ -z "$ignore_grep" ]; then
        find ~/.local/bin -type f -executable -printf "%f\n" | sort
    else
        find ~/.local/bin -type f -executable -printf "%f\n" | grep -vE "$ignore_grep" | sort
    fi
}

# extract many different file types
# usage: `extract filename`
extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.tar.xz) tar xJf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# create new directory and cd into it
mkcd() {
    mkdir -p -- "$1" &&
        cd -P -- "$1"
}

# print current git branch in a clean way
git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

cheat() {
    curl "https://cheat.sh/${1}"
}

# fshow - git commit browser
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# git log show with fzf
gli() {

    # param validation
    if [[ ! $(git log -n 1 $@ | head -n 1) ]]; then
        return
    fi

    # filter by file string
    local filter
    # param existed, git log for file if existed
    if [ -n $@ ] && [ -f $@ ]; then
        filter="-- $@"
    fi

    # git command
    local gitlog=(
        git log
        --graph --color=always
        --abbrev=7
        --format='%C(auto)%h %an %C(blue)%s %C(yellow)%cr'
        $@
    )

    # fzf command
    local fzf=(
        fzf
        --ansi --no-sort --reverse --tiebreak=index
        --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show --color=always \$1 $filter; }; f {}"
        --bind "ctrl-q:abort,ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % $filter | less -R') << 'FZF-EOF'
                {}
                FZF-EOF"
        --preview-window=right:60%
    )

    # piping them
    $gitlog | $fzf
}
