#!/usr/bin/env bash
# Claude Code status line — styled after Oh My Zsh robbyrussell theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Current directory basename (like %c in robbyrussell)
dir_name=$(basename "$cwd")

# Git branch (skip optional locks to avoid contention)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null)
fi

# Build the prompt string using ANSI colors
CYAN="\033[0;36m"
RED="\033[0;31m"
BLUE="\033[1;34m"
YELLOW="\033[0;33m"
RESET="\033[0m"

output=""

# Directory (cyan, like robbyrussell %c)
output="${output}$(printf "${CYAN}%s${RESET}" "$dir_name")"

# Git branch (blue+red like robbyrussell)
if [ -n "$git_branch" ]; then
  output="${output} $(printf "${BLUE}git:(${RED}%s${BLUE})${RESET}" "$git_branch")"
fi

# Model name
if [ -n "$model" ]; then
  output="${output} | ${model}"
fi

# Context usage
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  output="${output} ctx:${used_int}%"
fi

printf "%s" "$output"
