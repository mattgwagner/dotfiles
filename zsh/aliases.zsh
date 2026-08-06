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
