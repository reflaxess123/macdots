#!/bin/bash

# Получение температуры CPU
TEMP=$(sudo powermetrics --sample-count 1 --samplers smc -n 1 2>/dev/null | grep "CPU die temperature" | awk '{print $4}' | sed 's/C//' || echo "N/A")

if [[ "$TEMP" =~ ^[0-9]+$ ]]; then
    if [ "$TEMP" -gt 80 ]; then
        COLOR=0xFFFF6B6B
    elif [ "$TEMP" -gt 60 ]; then
        COLOR=0xFFFFD93D
    else
        COLOR=0xFF6BCF7F
    fi
    sketchybar --set $NAME label="${TEMP}°C" icon.color="$COLOR" label.color="$COLOR"
else
    sketchybar --set $NAME label="N/A" icon.color=0xFFFFFFFF label.color=0xFFFFFFFF
fi