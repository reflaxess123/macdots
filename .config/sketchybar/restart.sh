#!/bin/bash

echo "Restarting SketchyBar and Yabai..."

# Stop services
brew services stop felixkratz/formulae/sketchybar
yabai --stop-service

# Wait a moment
sleep 2

# Start services
yabai --start-service
brew services start felixkratz/formulae/sketchybar

echo "Services restarted successfully!"