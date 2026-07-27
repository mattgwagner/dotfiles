# Jump into a named tmux session on the mini, creating it if it doesn't exist.
# Usage: mssh <session-name> [host]
#   mssh redleg-web            -> ssh mini, tmux new -A -s redleg-web
#   mssh redleg-web mini-remote -> same, over the external alias
mssh() {
  local session="${1:?usage: mssh <session-name> [host=mini]}"
  local host="${2:-mini}"
  ssh -t "$host" "tmux new -A -s '$session'"
}
