# Jump into a named tmux session on the mini, creating it if it doesn't exist.
# Usage: mssh <session-name> [host]
#   mssh redleg-web              -> auto-picks mini (LAN) or mini-remote (away)
#   mssh redleg-web mini-remote  -> force a specific host, skips the probe
mssh() {
  local session="${1:?usage: mssh <session-name> [host]}"
  local host="$2"
  if [[ -z "$host" ]]; then
    if ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini true 2>/dev/null; then
      host=mini
    else
      host=mini-remote
    fi
  fi
  ssh -t "$host" "tmux new -A -s '$session'"
}

alias yolo='claude --dangerously-skip-permissions --chrome'

# List (or otherwise operate on) tmux sessions on the mini.
# Usage: mtux ls [host]   -> list sessions
#        mtux <session>   -> shorthand for mssh <session>
mtux() {
  local cmd="${1:?usage: mtux ls|<session-name> [host]}"
  local host="$2"
  if [[ -z "$host" ]]; then
    if ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini true 2>/dev/null; then
      host=mini
    else
      host=mini-remote
    fi
  fi
  if [[ "$cmd" == "ls" ]]; then
    ssh -o ConnectTimeout=3 "$host" "tmux ls" 2>/dev/null
  else
    mssh "$cmd" "$host"
  fi
}
