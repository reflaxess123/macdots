#!/bin/bash

# Получаем громкость
if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME=$(osascript -e 'output volume of (get volume settings)')
fi

if [ "$VOLUME" -eq 0 ]; then
  COLOR=0xFFFF6B6B
else
  COLOR=0xFFFFFFFF
fi

sketchybar --set "$NAME" label="${VOLUME}%" icon.color="$COLOR" label.color="$COLOR"
