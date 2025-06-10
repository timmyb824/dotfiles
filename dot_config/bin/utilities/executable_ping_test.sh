#!/bin/bash

HOST=${1:-8.8.8.8}
LOGFILE="ping_log_$(date +%F).log"

echo "🌐 Pinging $HOST... logging to $LOGFILE"

ping -c 10 $HOST | tee -a $LOGFILE

LOSS=$(ping -c 10 $HOST | grep -oP '\d+(?=% packet loss)')

if [ "$LOSS" -gt 0 ]; then
    echo "⚠️ Warning: $LOSS% packet loss detected for $HOST" | tee -a $LOGFILE
else
    echo "✅ Network to $HOST is stable." | tee -a $LOGFILE
fi
