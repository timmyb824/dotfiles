#!/bin/bash

DIR=${1:-.}

if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is not a directory"
    exit 1
fi

echo "🔎 Searching for the biggest files in: $DIR"
echo "--------------------------------------------"

find "$DIR" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 10
