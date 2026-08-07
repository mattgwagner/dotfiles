# Startup banner — key custom commands + live context, shown on every new
# interactive shell. Mac-only (sourced from env.zsh); the mini has its own
# tmux auto-attach in ssh-tmux.zsh instead.
#
# The command table below is static text, not derived from aliases.zsh —
# update it by hand when adding/removing a command there.

[[ -o interactive ]] || return

_motd() {
  local dim reset
  dim=$(tput dim 2>/dev/null)
  reset=$(tput sgr0 2>/dev/null)

  local mini_status
  if ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini true 2>/dev/null; then
    mini_status="reachable (LAN)"
  elif ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o BatchMode=yes mini-remote true 2>/dev/null; then
    mini_status="away — use mini-remote"
  else
    mini_status="unreachable"
  fi

  local foundry_status="default"
  if [[ "$CLAUDE_CODE_USE_FOUNDRY" == "1" ]]; then
    case "$ANTHROPIC_FOUNDRY_RESOURCE" in
      incontext-azure-foundry-eastus2) foundry_status="incontext" ;;
      foundry-sittadel-prod) foundry_status="sittadel" ;;
      *) foundry_status="$ANTHROPIC_FOUNDRY_RESOURCE" ;;
    esac
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
│ foundry: ${foundry_status}
│ tmux:    ${tmux_status}${reset}
└─────────────────────────────────────────────────────────
EOF
}

_motd
unset -f _motd
