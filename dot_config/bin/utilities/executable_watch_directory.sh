#!/bin/bash

WATCH_DIR=${1:-/etc}
EVENTS="modify,create,delete,move"
LOGFILE="watch_$(basename $WATCH_DIR)_$(date +%F).log"

if [ ! -d "$WATCH_DIR" ]; then
    echo "Error: $WATCH_DIR is not a directory"
    exit 1
fi

if command -v inotifywait >/dev/null 2>&1; then
    echo "👁️ Watching $WATCH_DIR for changes..."
    inotifywait -m -r -e $EVENTS "$WATCH_DIR" --format '%T %w%f %e' --timefmt '%F %T' | tee -a "$LOGFILE"
else
    echo "Error: inotifywait is not installed"
    echo "Please install inotify-tools to use this script:"
    echo "sudo apt-get install inotify-tools"
    exit 1
fi
