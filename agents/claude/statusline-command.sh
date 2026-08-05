#!/usr/bin/env bash
# Claude Code status line: model, repository, branch, context, cost, and time.
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tokens=$(echo "$input" | jq -r '
  (.context_window.current_usage // {}) as $u |
  (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) as $t |
  if $t > 0 then $t else empty end')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
dur_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

esc=$'\e'
bel=$'\a'
reset="${esc}[0m"
dim="${esc}[2m"
green="${esc}[0;32m"
cyan="${esc}[0;36m"
bcyan="${esc}[1;36m"
bblue="${esc}[1;34m"
yellow="${esc}[0;33m"
red="${esc}[0;31m"

osc8() { printf '%s]8;;%s%s%s%s]8;;%s' "$esc" "$1" "$bel" "$2" "$esc" "$bel"; }

case "$model" in
  *Opus*)   model_short="Opus" ;;
  *Sonnet*) model_short="Sonnet" ;;
  *Haiku*)  model_short="Haiku" ;;
  *)        model_short="$model" ;;
esac

branch=""
dirty=""
repo_url=""
branch_url=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if ! git -C "$cwd" diff --quiet 2>/dev/null \
    || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
    dirty=" ${yellow}✗${reset}"
  fi
  remote=$(git -C "$cwd" remote get-url origin 2>/dev/null \
    | sed -e 's#^git@\([^:]*\):#https://\1/#' -e 's#\.git$##')
  if [[ "$remote" == https://* ]]; then
    repo_url="$remote"
    [ -n "$branch" ] && branch_url="${remote}/tree/${branch}"
  fi
fi
[ -z "$repo_url" ] && repo_url="file://${cwd}"

ctx_display=""
if [ -n "$used" ] || [ -n "$tokens" ]; then
  pct=0
  [ -n "$used" ] && pct=$(printf "%.0f" "$used")
  [ "$pct" -gt 100 ] && pct=100
  ctx_color="$green"
  [ "$pct" -ge 60 ] && ctx_color="$yellow"
  [ "$pct" -ge 85 ] && ctx_color="$red"

  tok_str=""
  if [ -n "$tokens" ]; then
    if [ "$tokens" -ge 1000000 ]; then
      tok_str=$(awk -v t="$tokens" 'BEGIN{printf "%.1fM", t/1000000}')
    elif [ "$tokens" -ge 1000 ]; then
      tok_str=$(awk -v t="$tokens" 'BEGIN{printf "%.1fk", t/1000}')
    else
      tok_str="${tokens}"
    fi
    ctx_display="${ctx_color}${tok_str} tokens${reset} ${dim}(${pct}%)${reset}"
  else
    ctx_display="${ctx_color}${pct}%${reset}"
  fi
fi

cost_display=""
if [ -n "$cost" ]; then
  session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
  transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
  state_dir="${TMPDIR:-/tmp}/claude-statusline"
  mkdir -p "$state_dir" 2>/dev/null
  state_file="$state_dir/${session_id}.state"

  prev_transcript=""
  baseline_cost="0"
  if [ -r "$state_file" ]; then
    prev_transcript=$(sed -n '1p' "$state_file" 2>/dev/null)
    baseline_cost=$(sed -n '2p' "$state_file" 2>/dev/null)
  fi
  if [ "$prev_transcript" != "$transcript_path" ]; then
    baseline_cost="$cost"
    printf '%s\n%s\n' "$transcript_path" "$cost" > "$state_file"
  fi

  session_cost=$(printf '%.2f' "$cost")
  chat_cost=$(awk -v t="$cost" -v b="$baseline_cost" 'BEGIN{printf "%.2f", t-b}')
  cost_display="\$${session_cost}${reset}${dim} session${reset}${yellow} · \$${chat_cost}${reset}${dim} chat"
fi

dur_display=""
if [ -n "$dur_ms" ]; then
  secs=$(( dur_ms / 1000 ))
  if [ "$secs" -ge 3600 ]; then
    dur_display="$((secs/3600))h $(((secs%3600)/60))m"
  elif [ "$secs" -ge 60 ]; then
    dur_display="$((secs/60))m $((secs%60))s"
  else
    dur_display="${secs}s"
  fi
fi

sep=" ${dim}|${reset} "
repo_link=$(osc8 "$repo_url" "${cyan}${dir}${reset}")
line1="${bcyan}[${model_short}]${reset} 📁 ${repo_link}"
if [ -n "$branch" ]; then
  if [ -n "$branch_url" ]; then
    branch_link=$(osc8 "$branch_url" "${bblue}${branch}${reset}")
  else
    branch_link="${bblue}${branch}${reset}"
  fi
  line1+="${sep}🌿 ${branch_link}${dirty}"
fi

line2=""
add() { [ -z "$line2" ] && line2="$1" || line2+="${sep}$1"; }
[ -n "$ctx_display" ]  && add "$ctx_display"
[ -n "$cost_display" ] && add "${yellow}${cost_display}${reset}"
[ -n "$dur_display" ]   && add "⏱  ${dur_display}"

printf '%s\n' "$line1"
[ -n "$line2" ] && printf '%s\n' "$line2"
