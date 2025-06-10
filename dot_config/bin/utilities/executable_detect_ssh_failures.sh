#!/bin/bash

LOG_FILE="/var/log/auth.log"
OUTPUT_FILE="ssh_failures_$(date +%F).log"

echo "🛡️ Detecting failed SSH login attempts..."
grep "Failed password" "$LOG_FILE" | awk '{print $1, $2, $3, $11}' | sort | uniq -c | sort -nr >"$OUTPUT_FILE"

echo "📄 Report saved to $OUTPUT_FILE"
cat "$OUTPUT_FILE"
