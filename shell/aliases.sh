# Shared aliases and helpers. Sourced from BOTH ~/.zshrc (Macs) and ~/.bashrc
# (Omarchy), so keep everything POSIX-compatible — no `print -r`, no zsh
# arrays. Shell-specific bits belong behind a $ZSH_VERSION guard.

# Canonical agent host. `andy` is a Tailscale MagicDNS name, so it resolves
# identically on the LAN and away — which is why there is no longer a
# reachable-vs-remote probe here. The old _mini_host helper existed only
# because the mini was mDNS-only (`matts-mac-mini.local`), and mDNS
# resolution is NOT bounded by ConnectTimeout: off-LAN it hung every shell
# for seconds before falling through to the remote alias. Tailscale removes
# the whole problem. Deliberately host-neutral: the box behind it has already
# changed once (mini -> Beelink) and will again.
ANDY_HOST="${ANDY_HOST:-andy}"

# Get to work: attach to Herdr on the agent host. One persistent session; each
# project is a workspace inside it (prefix+w to pick, prefix+shift+n for a new
# one), so there's nothing to name or create out here.
#
# --remote-keybindings server is deliberate. Herdr defaults to "local", which
# reads the keymap from the *client* machine — so a laptop whose
# ~/.config/herdr/config.toml is missing or stock silently attaches with
# Herdr's default ctrl+b prefix instead of ours, and the failure looks like
# the terminal eating the keystroke. The agent host owns the session, so let
# it own the keymap too: one source of truth, and a machine that has never run
# script/bootstrap-shell still gets the right keys.
#
# Usage: work [host]
#   work          -> $ANDY_HOST (default: andy)
#   work mini     -> force a specific host
work() {
  herdr --remote "${1:-$ANDY_HOST}" --remote-keybindings server
}

alias yolo='claude --dangerously-skip-permissions --chrome'
