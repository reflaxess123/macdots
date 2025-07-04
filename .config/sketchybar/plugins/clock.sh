#!/bin/bash

# Часы как в Waybar - время и дата
TIME_DATE=$(date '+%H:%M %d/%m/%Y')
sketchybar --set "$NAME" label="$TIME_DATE"

