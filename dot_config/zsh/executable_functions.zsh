# list non-symlinked and non-ignored executables in .local/bin
list_local_bin() {
    echo "Listing all non-symlinked executables in ~/.local/bin"

    # Define the list of executables to ignore
    ignore_list="code"

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
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
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
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
