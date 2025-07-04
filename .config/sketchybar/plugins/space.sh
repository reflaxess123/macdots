#!/bin/bash

# Улучшенный индикатор пространств с цифрами
SID=$(echo $NAME | cut -d'.' -f2)
WIN_COUNT=$(yabai -m query --windows --space $SID 2>/dev/null | jq 'length' 2>/dev/null || echo 0)

if [ $SELECTED = true ]; then
  # Активное пространство - яркий синий цвет
  sketchybar --set $NAME icon.color=0xFF4A90E2 \
                         label.color=0xFF4A90E2 \
                         icon.font="SF Pro:Bold:20.0"
else
  if [ $WIN_COUNT -gt 0 ]; then
    # Пространство с окнами - белый цвет
    sketchybar --set $NAME icon.color=0xFFFFFFFF \
                           label.color=0xFFFFFFFF \
                           icon.font="SF Pro:Medium:18.0"
  else
    # Пустое пространство - серый цвет
    sketchybar --set $NAME icon.color=0x80FFFFFF \
                           label.color=0x80FFFFFF \
                           icon.font="SF Pro:Medium:18.0"
  fi
fi
