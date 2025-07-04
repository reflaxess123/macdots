#!/bin/bash

# Показываем детальную информацию о температуре
TEMP_INFO=$(sudo powermetrics --sample-count 1 --samplers smc -n 1 2>/dev/null | grep "temperature" || echo "Temperature information not available")

osascript -e "display notification \"Temperature Information:
$TEMP_INFO\" with title \"CPU Temperature\""