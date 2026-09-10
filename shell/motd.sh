# Startup banner — key custom commands + live context, shown on every new
# interactive shell on any machine (Mac laptop, or the Omarchy agent host). It
# shows once on SSH login and again per new Herdr pane/tab (each spawns its
# own shell).
#
# Sourced from BOTH ~/.zshrc and ~/.bashrc — keep it POSIX-compatible.
#
# The command and keybinding tables below are static text, not derived from
# aliases.zsh or terminal/herdr.toml — update them by hand when either
# changes. Keybindings must match terminal/herdr.toml, including which split
# goes right vs down.
#
# Agent-host reachability is read from a cache file, never probed live here.
# The original reason was mDNS: `matts-mac-mini.local` resolution is NOT
# bounded by ConnectTimeout, so off-LAN every new shell paid 5s+. The host is
# now a Tailscale name that resolves fast, but the async cache is kept — a
# down tailnet or a sleeping host can still block, and a banner must never be
# able to hang a shell. _motd_refresh_agent_status runs the real probe
# detached and writes the result for the *next* shell to read instantly.

# Interactive check, portable across zsh and bash ([[ -o interactive ]] is
# zsh-only).
case $- in *i*) ;; *) return ;; esac

_MOTD_AGENT_CACHE="${TMPDIR:-/tmp}/dotfiles-agent-status.${UID:-$(id -u)}"
_MOTD_AGENT_CACHE_TTL=120 # seconds
_MOTD_AGENT_HOST="${ANDY_HOST:-andy}"

_motd_refresh_agent_status() {
  (
    reach="unreachable"
    if ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes \
         "$_MOTD_AGENT_HOST" true 2>/dev/null; then
      reach="reachable"
    fi
    printf '%s\n' "$reach" > "$_MOTD_AGENT_CACHE"
  ) &
  # zsh spells this `&!`; `& disown` is the portable form. Suppressed because
  # bash's disown errors when job control is off (non-interactive parent).
  disown 2>/dev/null || true
}

_motd() {
  dim=$(tput dim 2>/dev/null)
  reset=$(tput sgr0 2>/dev/null)

  agent_status=""
  # On the agent host itself there is nothing to probe. Matched by hostname
  # rather than a fixed string so it survives the next hardware swap.
  case "$(hostname -s)" in
    omarchy|Matts-Mac-mini*) agent_status="local (you're on it)" ;;
  esac
  if [ -z "$agent_status" ]; then
    cache_age=-1
    [ -f "$_MOTD_AGENT_CACHE" ] && \
      cache_age=$(( $(date +%s) - $(date -r "$_MOTD_AGENT_CACHE" +%s) ))
    if [ "$cache_age" -ge 0 ] && [ "$cache_age" -lt "$_MOTD_AGENT_CACHE_TTL" ]; then
      agent_status="$(cat "$_MOTD_AGENT_CACHE")"
    else
      # Stale or missing — show what we can and kick a refresh for the next
      # shell. Only spawn the probe when actually stale, so opening a bunch
      # of Herdr panes back-to-back doesn't fire a redundant ssh per pane.
      agent_status="checking… (next shell will show it)"
      _motd_refresh_agent_status
    fi
  fi

  herdr_status="not active"
  [ -n "$HERDR_ENV" ] && herdr_status="active (${HERDR_WORKSPACE_ID:-?}/${HERDR_PANE_ID:-?})"

  cat <<EOF
┌─ dotfiles ────────────────────────────────────────────────
│ work [host]              attach to Herdr on andy
│ yolo                     claude, skip permissions + chrome
│ use-incontext-foundry    open Claude Code with InContext Foundry
│ use-sittadel-foundry     open Claude Code with Sittadel Foundry
├─ herdr · prefix ^A · caps = shift · ^A ? = all keys ──────
│ ^A c   new tab            ^A v  split right
│ ^A w   workspace picker   ^A -  split down
│ ^A N   new workspace      ^A x  close pane
│ ^A W   rename workspace   ^A z  zoom pane
│ ^1..9  switch tab         ^A q  detach
├───────────────────────────────────────────────────────────
│ ${dim}andy:    ${agent_status}
│ herdr:   ${herdr_status}${reset}
└───────────────────────────────────────────────────────────
EOF
}

_motd
unset -f _motd
# _motd_refresh_agent_status stays defined — the backgrounded subshell that
# calls it needs it to still exist when it actually runs.
