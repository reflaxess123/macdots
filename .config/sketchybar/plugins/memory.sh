#!/bin/bash

# Более точный способ получения информации о памяти
MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "50")
MEMORY_USAGE=$((100 - MEMORY_PRESSURE))

# Альтернативный метод через vm_stat
if [ -z "$MEMORY_USAGE" ] || [ "$MEMORY_USAGE" -eq 0 ]; then
    VM_STAT=$(vm_stat)
    PAGE_SIZE=$(vm_stat | grep "page size" | awk '{print $8}' | sed 's/\.//')
    PAGES_FREE=$(echo "$VM_STAT" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    PAGES_ACTIVE=$(echo "$VM_STAT" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    PAGES_INACTIVE=$(echo "$VM_STAT" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    PAGES_WIRED=$(echo "$VM_STAT" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    
    TOTAL_PAGES=$((PAGES_FREE + PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED))
    USED_PAGES=$((PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED))
    MEMORY_USAGE=$((USED_PAGES * 100 / TOTAL_PAGES))
fi

if [ "$MEMORY_USAGE" -gt 80 ]; then
  COLOR=0xFFFF6B6B
elif [ "$MEMORY_USAGE" -gt 60 ]; then
  COLOR=0xFFFFD93D
else
  COLOR=0xFF6BCF7F
fi

sketchybar --set $NAME label="${MEMORY_USAGE}%" icon.color="$COLOR" label.color="$COLOR"