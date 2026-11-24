#!/bin/bash
# Auto commit + integrate + push the whole vault. Multi-node safe (omarchy, thinkstation;
# the MacBook runs its own memory-backup.sh). Source: dotfiles terminal/, symlinked into
# ~/.local/bin on each Linux node.
# Self-healing: clears abandoned rebase/merge state so one bad cycle can't wedge the
# hourly job forever (the recurring "non-fast-forward" doom loop). Uses merge, not
# rebase, so a conflict aborts cleanly instead of leaving in-progress state behind.
export PATH="/usr/bin:/bin:$HOME/.local/bin:$HOME/.local/share/mise/shims"
REPO="$HOME/vault"
BRANCH=main
NODE="${VAULT_NODE:-$(hostname -s)}"
[ "$NODE" = omarchy ] && NODE=beelink   # historical label in commit authors and alerts
cd "$REPO" || exit 0

# Single-instance lock so overlapping runs can't race (atomic mkdir).
LOCK="$REPO/.git/vault-backup.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  # Stale lock older than 30 min? reclaim it.
  if [ -n "$(find "$LOCK" -maxdepth 0 -mmin +30 2>/dev/null)" ]; then
    rmdir "$LOCK" 2>/dev/null; mkdir "$LOCK" 2>/dev/null || exit 0
  else
    exit 0
  fi
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Telegram Matt when the job is stuck, so a wedged node can't go unnoticed for weeks.
# Counts consecutive stuck cycles (conflict / rejected push; a fetch failure is just offline).
FAILS="$REPO/.git/vault-backup.fails"
TG_TOKEN=$(sed -n 's/^TELEGRAM_BOT_TOKEN=//p' "/home/matt/.hermes/.env" 2>/dev/null | tr -d "\"'")
TG_CHAT=$(sed -n 's/^TELEGRAM_HOME_CHANNEL=//p' "/home/matt/.hermes/.env" 2>/dev/null | tr -d "\"'")
alert() {
  [ -n "$TG_TOKEN" ] && [ -n "$TG_CHAT" ] || return 0
  curl -fsS -m 20 "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TG_CHAT}" --data-urlencode "text=$1" >/dev/null 2>&1 || log "telegram alert failed"
}
stuck() {
  log "$1"
  n=$(( $(cat "$FAILS" 2>/dev/null || echo 0) + 1 )); echo "$n" > "$FAILS"
  if [ "$n" -eq 2 ] || [ $(( n % 24 )) -eq 2 ]; then
    alert "Vault backup on ${NODE} stuck for $n cycles: $1. vault-merge-repair refused, so this needs a manual merge in ~/vault (runbook: reference_vault_git_hazards)."
  fi
}

# 1. Self-heal any abandoned state from a prior interrupted run. THIS is the fix for
#    the recurring breakage: previously an abandoned rebase silently wedged every
#    subsequent hourly push until a human cleared it by hand.
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  log "WARN abandoned rebase found -> abort"; git rebase --abort 2>/dev/null || true
fi
if [ -f .git/MERGE_HEAD ]; then
  log "WARN abandoned merge found -> abort"; git merge --abort 2>/dev/null || true
fi
rm -f .git/REBASE_HEAD .git/CHERRY_PICK_HEAD 2>/dev/null

# 2. Commit local changes first (no autostash juggling).
git add -A
if ! git diff --cached --quiet; then
  git -c user.name="Andy-${NODE}" \
      commit -q -m "auto: vault snapshot (${NODE}) $(date '+%Y-%m-%d %H:%M')" || true
fi

# 3. Integrate remote via merge. A conflict aborts cleanly (never leaves the repo
#    wedged), then vault-merge-repair resolves it from the Obsidian-converged live
#    files in a side worktree, only when it can prove they hold both sides' lines.
repair() {
  local out
  if out=$(GIT_AUTHOR_NAME="Andy-${NODE}" GIT_COMMITTER_NAME="Andy-${NODE}" vault-merge-repair 2>&1); then log "conflict auto-repaired: $out"; return 0; fi
  stuck "ERROR $1, auto-repair refused: $out"; return 1
}
git fetch -q origin "$BRANCH" || { log "fetch failed, retry next cycle"; exit 0; }
if ! git merge -q --no-edit origin/"$BRANCH"; then
  git merge --abort 2>/dev/null || true
  repair "merge conflict" || exit 0
fi

# 4. Push, with one retry if another node pushed between our fetch and push.
if ! git push -q origin "$BRANCH" 2>/dev/null; then
  git fetch -q origin "$BRANCH"
  if git merge -q --no-edit origin/"$BRANCH"; then
    git push -q origin "$BRANCH" 2>/dev/null || { stuck "push still rejected, retry next cycle"; exit 0; }
  else
    git merge --abort 2>/dev/null || true
    repair "conflict on retry" || exit 0
    git push -q origin "$BRANCH" 2>/dev/null || { stuck "push still rejected, retry next cycle"; exit 0; }
  fi
fi
[ "$(cat "$FAILS" 2>/dev/null || echo 0)" -ge 2 ] && alert "Vault backup on ${NODE} recovered."
rm -f "$FAILS"
log "ok $(git rev-parse --short HEAD)"
