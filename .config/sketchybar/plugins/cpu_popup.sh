#!/bin/bash

# Показываем детальную информацию о CPU
CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
CPU_CORES=$(sysctl -n hw.ncpu)
CPU_FREQ=$(sysctl -n hw.cpufrequency_max 2>/dev/null || echo "Unknown")

osascript -e "display notification \"CPU: $CPU_INFO
Cores: $CPU_CORES
Frequency: $CPU_FREQ\" with title \"CPU Information\""