# Remote SSH quality-of-life — install on the mini, not the Mac.
#
# Auto-attach to a tmux session named "main" whenever logging into the mini
# over SSH without already specifying a session, so a stray/forgotten
# terminal still lands in a persistent workspace instead of a bare shell.
# Named per-project sessions (mssh <project>) bypass this entirely since
# they specify their own session name before this ever runs.
#
# Skips non-interactive shells (scp/rsync) and avoids nesting tmux in tmux.
# Set NO_AUTO_TMUX=1 to disable.

[[ -o interactive ]] || return

if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -z "$NO_AUTO_TMUX" ]]; then
  tmux new -A -s main
fi
