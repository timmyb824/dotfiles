#!/bin/bash

DIR_TO_ARCHIVE=${1:-/var/log}
DEST_DIR=${2:-~/archives}
TIMESTAMP=$(date +"%F_%H-%M-%S")
ARCHIVE_NAME=$(basename "$DIR_TO_ARCHIVE")_"$TIMESTAMP".tar.gz

mkdir -p "$DEST_DIR"

echo "📦 Archiving $DIR_TO_ARCHIVE into $DEST_DIR/$ARCHIVE_NAME..."
tar -czf "$DEST_DIR/$ARCHIVE_NAME" "$DIR_TO_ARCHIVE"

if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully!"
else
    echo "❌ Archive failed."
fi
