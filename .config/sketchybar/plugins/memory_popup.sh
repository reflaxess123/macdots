#!/bin/bash

# Показываем детальную информацию о памяти
MEMORY_INFO=$(system_profiler SPHardwareDataType | grep "Memory:")
VM_STAT=$(vm_stat)

osascript -e "display notification \"$MEMORY_INFO
VM Statistics:
$VM_STAT\" with title \"Memory Information\""