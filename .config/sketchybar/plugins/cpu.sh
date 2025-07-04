#!/bin/bash

CPU_USAGE=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
CPU_USAGE=${CPU_USAGE%.*}

if [ "$CPU_USAGE" -gt 75 ]; then
  COLOR=0xFFFF6B6B
elif [ "$CPU_USAGE" -gt 50 ]; then
  COLOR=0xFFFFD93D
else
  COLOR=0xFF6BCF7F
fi

sketchybar --set $NAME label="${CPU_USAGE}%" icon.color="$COLOR" label.color="$COLOR"