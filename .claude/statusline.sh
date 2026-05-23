#!/usr/bin/env bash
# Claude Code status line
# Format: 📁 <dir>  ⎇ <branch>(+N,-N)  🤖 <Model> <style> <pct>% <k>k  ● 5h <pct>% <time>  ● <pct>% <time>

input=$(cat)

# ── 1. Directory ────────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir_name=$(basename "$cwd")

# ── 2. Git branch + diff stat ────────────────────────────────────────────────
git_segment=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    added=0
    deleted=0
    while IFS= read -r line; do
      a=$(echo "$line" | awk '{print $1}')
      d=$(echo "$line" | awk '{print $2}')
      # Skip binary files (shown as "-")
      if [[ "$a" =~ ^[0-9]+$ ]]; then added=$((added + a)); fi
      if [[ "$d" =~ ^[0-9]+$ ]]; then deleted=$((deleted + d)); fi
    done < <(git -C "$cwd" -c core.fsmonitor=false diff --numstat HEAD 2>/dev/null)
    git_segment="⎇ ${branch}(+${added},-${deleted})"
  fi
fi

# ── 3. Model + output style + context usage ──────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // empty')
style=$(echo "$input" | jq -r '.output_style.name // empty')

# Strip common default style names so we only show meaningful ones
if [[ "$style" == "default" || "$style" == "Default" || "$style" == "null" ]]; then
  style=""
fi

# Effort level (e.g. xhigh) – append when present
effort=$(echo "$input" | jq -r '.effort.level // empty')

# Context window
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

model_segment=""
if [ -n "$model" ]; then
  model_segment="👾 ${model}"
  [ -n "$effort" ]   && model_segment="${model_segment} ${effort}"
  [ -n "$style" ]    && model_segment="${model_segment} ${style}"

  if [ -n "$used_pct" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
    used_pct_fmt=$(printf "%.1f" "$used_pct")
    # Total tokens used (input + output), formatted as Nk with one decimal
    total_tokens=$((total_input + total_output))
    tokens_k=$(awk "BEGIN {printf \"%.1f\", $total_tokens / 1000}")
    model_segment="${model_segment} ${used_pct_fmt}% ${tokens_k}k"
  fi
fi

# ── 4 & 5. Rate limits from ccusage ─────────────────────────────────────────
# Cache ccusage output for 10 seconds to keep the status line fast
CACHE_FILE="/tmp/.claude_ccusage_cache"
CACHE_TTL=10

ccusage_json=""
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    ccusage_json=$(cat "$CACHE_FILE")
  fi
fi

if [ -z "$ccusage_json" ]; then
  ccusage_json=$(npx -y ccusage@latest blocks --json 2>/dev/null)
  if [ -n "$ccusage_json" ]; then
    echo "$ccusage_json" > "$CACHE_FILE"
  fi
fi

# Helper: convert unix epoch seconds to a "Xhr Ym" or "Nd Xhr Ym" string
secs_to_human() {
  local secs=$1
  if [ -z "$secs" ] || [ "$secs" -le 0 ] 2>/dev/null; then
    echo "--"
    return
  fi
  local days=$(( secs / 86400 ))
  local hrs=$(( (secs % 86400) / 3600 ))
  local mins=$(( (secs % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    printf "%dd %dhr %dm" "$days" "$hrs" "$mins"
  else
    printf "%dhr %dm" "$hrs" "$mins"
  fi
}

now=$(date +%s)

five_segment="● 5h --"
week_segment="● --"

if [ -n "$ccusage_json" ] && echo "$ccusage_json" | jq -e . >/dev/null 2>&1; then
  # 5-hour block: find the active block (isActive=true or the most recent)
  five_pct=$(echo "$ccusage_json" | jq -r '
    ( .blocks // [] | map(select(.isActive == true)) | first )
    // ( .blocks // [] | last )
    | .usedPercentage // empty
  ' 2>/dev/null)

  five_resets=$(echo "$ccusage_json" | jq -r '
    ( .blocks // [] | map(select(.isActive == true)) | first )
    // ( .blocks // [] | last )
    | .projection.windowEnd // .endTime // empty
  ' 2>/dev/null)

  # Also try the rate_limits fields coming directly from the status JSON
  if [ -z "$five_pct" ]; then
    five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
    five_resets_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  else
    # ccusage endTime is an ISO-8601 string; convert to epoch
    five_resets_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${five_resets%%.*}" "+%s" 2>/dev/null \
      || date -d "$five_resets" +%s 2>/dev/null \
      || echo "")
  fi

  if [ -n "$five_pct" ]; then
    five_pct_fmt=$(printf "%.1f" "$five_pct")
    five_remaining_secs=""
    if [ -n "$five_resets_epoch" ] && [ "$five_resets_epoch" -gt "$now" ] 2>/dev/null; then
      five_remaining_secs=$(( five_resets_epoch - now ))
    fi
    five_time=$(secs_to_human "$five_remaining_secs")
    five_segment="● 5h ${five_pct_fmt}% ${five_time}"
  fi

  # Weekly block
  week_pct=$(echo "$ccusage_json" | jq -r '.weekly.usedPercentage // empty' 2>/dev/null)
  week_resets=$(echo "$ccusage_json" | jq -r '.weekly.projection.windowEnd // .weekly.endTime // empty' 2>/dev/null)

  if [ -z "$week_pct" ]; then
    week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
    week_resets_epoch=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
  else
    week_resets_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${week_resets%%.*}" "+%s" 2>/dev/null \
      || date -d "$week_resets" +%s 2>/dev/null \
      || echo "")
  fi

  if [ -n "$week_pct" ]; then
    week_pct_fmt=$(printf "%.1f" "$week_pct")
    week_remaining_secs=""
    if [ -n "$week_resets_epoch" ] && [ "$week_resets_epoch" -gt "$now" ] 2>/dev/null; then
      week_remaining_secs=$(( week_resets_epoch - now ))
    fi
    week_time=$(secs_to_human "$week_remaining_secs")
    week_segment="● ${week_pct_fmt}% ${week_time}"
  fi
else
  # Fall back to rate_limits from the status JSON if ccusage is unavailable
  five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
  five_resets_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
  week_resets_epoch=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

  if [ -n "$five_pct" ]; then
    five_pct_fmt=$(printf "%.1f" "$five_pct")
    five_remaining_secs=""
    if [ -n "$five_resets_epoch" ] && [ "$five_resets_epoch" -gt "$now" ] 2>/dev/null; then
      five_remaining_secs=$(( five_resets_epoch - now ))
    fi
    five_time=$(secs_to_human "$five_remaining_secs")
    five_segment="● 5h ${five_pct_fmt}% ${five_time}"
  fi

  if [ -n "$week_pct" ]; then
    week_pct_fmt=$(printf "%.1f" "$week_pct")
    week_remaining_secs=""
    if [ -n "$week_resets_epoch" ] && [ "$week_resets_epoch" -gt "$now" ] 2>/dev/null; then
      week_remaining_secs=$(( week_resets_epoch - now ))
    fi
    week_time=$(secs_to_human "$week_remaining_secs")
    week_segment="● ${week_pct_fmt}% ${week_time}"
  fi
fi

# ── Assemble ─────────────────────────────────────────────────────────────────
parts=()
parts+=("🗂️ ${dir_name}")
[ -n "$git_segment" ]   && parts+=("$git_segment")
[ -n "$model_segment" ] && parts+=("$model_segment")
parts+=("$five_segment")
parts+=("$week_segment")

# Join with two spaces
output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="${output}  ${part}"
  fi
done

printf "%s" "$output"
