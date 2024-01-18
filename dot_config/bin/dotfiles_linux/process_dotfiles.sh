#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

process_file() {
    local file_path="$1"
    local output_path="$2"

    while IFS= read -r line; do
        if [[ "$line" == *"onepasswordRead"* ]]; then
            # Extract the 1Password path
            local op_path=$(echo "$line" | grep -oP '(?<=onepasswordRead ").*(?=" }})')
            if [[ -n "$op_path" ]]; then
                # Fetch the secret from 1Password
                local secret=$(op read "$op_path" --session="$OP_SESSION_TOKEN")
                if [[ -n "$secret" ]]; then
                    # Replace the placeholder with the actual secret value
                    line=${line/\{\{ onepasswordRead \"$op_path\" \}\}/$secret}
                else
                    echo "Error: Unable to retrieve the secret for $op_path"
                    return 1
                fi
            fi
        fi
        echo "$line"
    done < "$file_path" > "$output_path"
}

# Predefined list of source files and their output paths
declare -A file_map
# Populate the file_map with the paths to your source templates and their output paths
# Example:
# file_map["/path/to/source/template1.tpl"]="/path/to/output/file1"
file_map["$HOME/dotfiles/dot_aicommits.tmpl"]="$HOME/.aicommits"
file_map["$HOME/dotfiles/dot_dblab.yaml.tmpl"]="$HOME/.dblab.yaml"
file_map["$HOME/dotfiles/dot_opencommit.tmpl"]="$HOME/.opencommit"
file_map["$HOME/dotfiles/dot_config/gitearc/dot_gitearc.tmpl"]="$HOME/.config/.gitearc"
file_map["$HOME/dotfiles/dot_config/wtf/private_config.yml.tmpl"]="$HOME/.config/wtf/config.yml"

# Check if the user wants to process the templates
if ask_yes_or_no "Do you want to process the templates into dotfiles?"; then
    # Attempt to sign into 1Password
    if 1password_sign_in; then
        echo "Signed in to 1Password successfully."
        echo "Processing templates..."

        # Process each file and copy it to the designated output path
        for file_path in "${!file_map[@]}"; do
            output_path="${file_map[$file_path]}"
            if [[ -f "$file_path" ]]; then
                echo "Processing $file_path..."
                process_file "$file_path" "$output_path"
                if [ $? -eq 0 ]; then
                    echo "Processed file $file_path and saved as $output_path"
                else
                    echo "Failed to process $file_path"
                    exit 1
                fi
            else
                echo "File $file_path does not exist."
            fi
        done
    else
        echo "Failed to sign in to 1Password."
        exit 1
    fi
else
    echo "Skipping template processing."
    exit 0
fi