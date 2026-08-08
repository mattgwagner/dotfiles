# Startup banner — key custom commands + live context, shown on every new
# interactive shell on any Mac (laptop or mini). On the mini, this is sourced
# right before ssh-tmux.zsh's auto-attach, so it shows once on SSH login and
# again per new tmux pane/window (each spawns its own shell).
#
# The command table below is static text, not derived from aliases.zsh —
# update it by hand when adding/removing a command there.
#
# Mini reachability is read from a cache file, never probed live here: `ssh
# mini` resolves `matts-mac-mini.local` via mDNS, and ConnectTimeout does NOT
# bound that resolution step — off the mini's LAN it can hang 5s+ before
# falling through to mini-remote, making every new shell pay that cost.
# _motd_refresh_mini_status runs the real probe in a detached background job
# and writes the result for the *next* shell to read instantly.

[[ -o interactive ]] || return

_MOTD_MINI_CACHE="${TMPDIR:-/tmp}/dotfiles-mini-status.$UID"
_MOTD_MINI_CACHE_TTL=120 # seconds

_motd_refresh_mini_status() {
  (
    local reach
    if ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini true 2>/dev/null; then
      reach="reachable (LAN)"
    elif ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini-remote true 2>/dev/null; then
      reach="away — use mini-remote"
    else
      reach="unreachable"
    fi
    print -r -- "$reach" > "$_MOTD_MINI_CACHE"
  ) &!
}

_motd() {
  local dim reset
  dim=$(tput dim 2>/dev/null)
  reset=$(tput sgr0 2>/dev/null)

  local mini_status
  if [[ "$(hostname -s)" == Matts-Mac-mini* ]]; then
    mini_status="local (you're on it)"
  else
    local cache_age=-1
    [[ -f "$_MOTD_MINI_CACHE" ]] && cache_age=$(( $(date +%s) - $(date -r "$_MOTD_MINI_CACHE" +%s) ))
    if (( cache_age >= 0 && cache_age < _MOTD_MINI_CACHE_TTL )); then
      mini_status="$(<$_MOTD_MINI_CACHE)"
    else
      # Stale or missing — show what we can and kick a refresh for the next
      # shell. Only spawn the probe when actually stale, so opening a bunch
      # of tmux panes back-to-back doesn't fire a redundant ssh per pane.
      mini_status="checking… (next shell will show it)"
      _motd_refresh_mini_status
    fi
  fi

  local tmux_status="not active"
  [[ -n "$TMUX" ]] && tmux_status="active ($(tmux display-message -p '#S' 2>/dev/null))"

  cat <<EOF
┌─ dotfiles ────────────────────────────────────────────────
│ mssh <session> [host]     jump into / create tmux session on the mini
│ mtux ls | <session>       list mini sessions, or shorthand for mssh
│ mkill [session]           kill a tmux session on the mini
│ yolo                      claude --dangerously-skip-permissions --chrome
│ use-incontext-foundry     switch to InContext Azure Foundry
│ use-sittadel-foundry      switch to Sittadel Azure Foundry
├─────────────────────────────────────────────────────────
│ ${dim}mini:    ${mini_status}
│ tmux:    ${tmux_status}${reset}
└─────────────────────────────────────────────────────────
EOF
}

_motd
unset -f _motd
# _motd_refresh_mini_status stays defined — the backgrounded subshell that
# calls it (&!) needs it to still exist when it actually runs.
