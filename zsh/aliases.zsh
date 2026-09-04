# Pick the reachable mini host alias: `mini` on the LAN, `mini-remote` off it.
# Both must exist in ~/.ssh/config.
_mini_host() {
  if [[ -n "$1" ]]; then
    print -r -- "$1"
  elif ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini true 2>/dev/null; then
    print -r -- mini
  else
    print -r -- mini-remote
  fi
}

# Get to work: attach to Herdr on the mini. One persistent session; each
# project is a workspace inside it (prefix+w to pick, prefix+shift+n for a new
# one), so there's nothing to name or create out here.
# Usage: work [host]
#   work              -> auto-picks mini (LAN) or mini-remote (away)
#   work mini-remote  -> force a specific host, skips the reachability probe
work() {
  herdr --remote "$(_mini_host "$1")"
}

alias yolo='claude --dangerously-skip-permissions --chrome'
