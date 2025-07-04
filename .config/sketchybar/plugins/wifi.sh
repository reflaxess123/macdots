#!/bin/bash

# Получение информации о Wi-Fi
WIFI_STATUS=$(networksetup -getairportnetwork en0 2>/dev/null)

if [[ "$WIFI_STATUS" == *"Wi-Fi Network"* ]]; then
    # Извлекаем имя сети
    WIFI_NAME=$(echo "$WIFI_STATUS" | cut -d':' -f2 | sed 's/^ *//')
    
    # Получаем уровень сигнала
    WIFI_STRENGTH=$(iwconfig en0 2>/dev/null | grep -o '[0-9]*/' | sed 's/\///' || echo "")
    
    if [ -z "$WIFI_STRENGTH" ]; then
        # Альтернативный способ через system_profiler
        WIFI_STRENGTH=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A1 "Signal / Noise" | tail -1 | awk '{print $1}' | sed 's/-//' || echo "")
    fi
    
    if [ -n "$WIFI_STRENGTH" ] && [ "$WIFI_STRENGTH" -gt 50 ]; then
        ICON="📶"
        COLOR=0xFF6BCF7F
    elif [ -n "$WIFI_STRENGTH" ] && [ "$WIFI_STRENGTH" -gt 30 ]; then
        ICON="📶"
        COLOR=0xFFFFD93D
    else
        ICON="📶"
        COLOR=0xFFFF6B6B
    fi
    
    sketchybar --set $NAME label="$WIFI_NAME" icon.color="$COLOR" label.color=0xFFFFFFFF
else
    sketchybar --set $NAME label="Disconnected" icon.color=0xFFFF6B6B label.color=0xFFFF6B6B
fi