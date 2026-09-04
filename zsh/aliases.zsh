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

# Attach to a named persistent Herdr session on the mini, creating it if it
# doesn't exist. Herdr keeps the session (and everything running in it) alive
# server-side, so detaching or dropping the SSH link doesn't kill your work.
# Usage: hmini [session-name] [host]
#   hmini                      -> attach to the default session
#   hmini readerful            -> auto-picks mini (LAN) or mini-remote (away)
#   hmini readerful mini-remote -> force a specific host, skips the probe
hmini() {
  local session="$1"
  local host="$(_mini_host "$2")"
  if [[ -n "$session" ]]; then
    herdr --remote "$host" --session "$session"
  else
    herdr --remote "$host"
  fi
}

# List the Herdr sessions on the mini (name, status, directory, socket).
# Usage: hls [host]
hls() {
  local host="$(_mini_host "$1")"
  ssh -o ConnectTimeout=3 "$host" 'herdr session list' 2>/dev/null
}

# Stop a named Herdr session on the mini — the counterpart to hmini. This kills
# what's running inside it, so it asks first.
# Usage: hkill <session-name> [host]
hkill() {
  local session="${1:?usage: hkill <session-name> [host]}"
  local host="$(_mini_host "$2")"
  print "hkill: stopping session '$session' on $host"
  read -q "?Anything running inside it dies. Continue? [y/N] " || { print; return 1 }
  print
  ssh -o ConnectTimeout=5 "$host" "herdr session stop '$session'"
}

alias yolo='claude --dangerously-skip-permissions --chrome'
