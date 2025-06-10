#!/bin/bash

echo "📊 System Health Report - $(date)"
echo "------------------------------------"

echo "🧠 Memory Usage:"
free -h
echo

echo "🔥 CPU Load:"
uptime
echo

echo "💾 Disk Space:"
df -h /
echo

echo "✅ Top 5 memory-hungry processes:"
ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 6
