#!/bin/bash

# Минималистичный индикатор пространств - только кружочки

SID=$(echo $NAME | cut -d'.' -f2)

if [ $SELECTED = true ]; then
  # Активное пространство - синий кружочек
  sketchybar --set $NAME icon.color=0xFF4A90E2
else
  # Неактивное пространство - серый прозрачный кружочек
  sketchybar --set $NAME icon.color=0x60ffffff
fi