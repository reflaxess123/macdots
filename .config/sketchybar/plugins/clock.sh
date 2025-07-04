#!/bin/bash

# Часы - сначала дата, потом время
TIME_DATE=$(date '+%d/%m/%Y %H:%M')
sketchybar --set "$NAME" label="$TIME_DATE"

