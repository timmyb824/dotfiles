list_local_bin() {
    echo "Listing all non-symlinked executables in ~/.local/bin"
    find ~/.local/bin -type f -executable -printf "%f\n" | sort
}