#!/bin/bash

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

# Определяем цвет в зависимости от уровня заряда
if [ "$PERCENTAGE" -gt 60 ]; then
  COLOR=0xFF6BCF7F
elif [ "$PERCENTAGE" -gt 20 ]; then
  COLOR=0xFFFFD93D
else
  COLOR=0xFFFF6B6B
fi

# Если заряжается, меняем цвет
if [[ "$CHARGING" != "" ]]; then
  COLOR=0xFF6BCF7F
  sketchybar --set "$NAME" label="${PERCENTAGE}% " icon.color="$COLOR" label.color="$COLOR"
else
  sketchybar --set "$NAME" label="${PERCENTAGE}%" icon.color="$COLOR" label.color="$COLOR"
fi