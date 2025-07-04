#!/bin/bash

# Показываем детальную информацию о диске
DISK_INFO=$(df -h /)
DISK_DETAILS=$(diskutil info / | head -20)

osascript -e "display notification \"Disk Usage:
$DISK_INFO

Disk Details:
$DISK_DETAILS\" with title \"Storage Information\""