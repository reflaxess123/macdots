#!/bin/bash

# Получение информации о диске
DISK_INFO=$(df -h / | tail -1)
DISK_USAGE=$(echo $DISK_INFO | awk '{print $5}' | sed 's/%//')
DISK_USED=$(echo $DISK_INFO | awk '{print $3}')
DISK_TOTAL=$(echo $DISK_INFO | awk '{print $2}')

if [ "$DISK_USAGE" -gt 90 ]; then
    COLOR=0xFFFF6B6B
elif [ "$DISK_USAGE" -gt 70 ]; then
    COLOR=0xFFFFD93D
else
    COLOR=0xFF6BCF7F
fi

sketchybar --set $NAME label="${DISK_USAGE}%" icon.color="$COLOR" label.color="$COLOR"