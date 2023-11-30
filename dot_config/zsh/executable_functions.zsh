list_local_bin() {
    echo "Listing all non-symlinked executables in ~/.local/bin"

    # Define the list of executables to ignore
    ignore_list=""

    # Prepare the grep command to ignore the executables
    ignore_grep=$(echo "$ignore_list" | tr ' ' '|')

    find ~/.local/bin -type f -executable -printf "%f\n" | grep -vE "$ignore_grep" | sort
}
