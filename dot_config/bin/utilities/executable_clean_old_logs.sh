TARGET_DIR=${1:-/var/log}
DAYS_OLD=${2:-7}

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_DIR is not a directory"
    exit 1
fi

echo "🧼 Cleaning up logs in $TARGET_DIR older than $DAYS_OLD days..."
find "$TARGET_DIR" -type f -name "*.log" -mtime +"$DAYS_OLD" -exec rm -v {} \;
echo "✅ Cleanup complete!"
