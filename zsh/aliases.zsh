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

# Tear down the tmux session you're sitting in (the counterpart to mssh).
# Killing the current session drops the attached client, so an `mssh` shell
# exits back to your laptop in one step.
# Usage: mkill [session-name]
#   mkill                -> kills the current session
#   mkill readerful      -> kills a named session from anywhere
mkill() {
  local session="$1"
  if [[ -z "$session" ]]; then
    if [[ -z "$TMUX" ]]; then
      print -u2 "mkill: not inside tmux; pass a session name"
      return 1
    fi
    session="$(tmux display-message -p '#S')"
  elif ! tmux has-session -t "=$session" 2>/dev/null; then
    print -u2 "mkill: no such session: $session"
    return 1
  fi

  # Warn about anything heavier than the session's login shells before nuking it.
  local -a procs
  procs=("${(@f)$(tmux list-panes -s -t "=$session" -F '#{pane_pid}' 2>/dev/null \
    | xargs -I{} pgrep -P {} 2>/dev/null \
    | xargs -I{} ps -o comm= -p {} 2>/dev/null)}")
  if (( ${#procs[@]} )) && [[ -n "$procs[1]" ]]; then
    print "mkill: '$session' is running: ${procs[*]:t}"
    read -q "?Kill it anyway? [y/N] " || { print; return 1 }
    print
  fi

  tmux kill-session -t "=$session"
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
