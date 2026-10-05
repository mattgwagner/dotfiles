# Switch which Claude subscription Claude Code bills against, without
# switching the setup. One set of skills, hooks, plugins, settings and
# transcripts; one login per account.
#
# Claude Code keeps everything under $CLAUDE_CONFIG_DIR (default ~/.claude),
# and with it set, .claude.json moves inside that directory too. So each
# extra account gets its own directory, where everything is a symlink back
# into ~/.claude EXCEPT what belongs to the account:
#
#   .credentials.json      the OAuth login (Keychain entry on macOS)
#   .claude.json           created by Claude Code itself: account, onboarding,
#                          per-project trust
#   backups/               copies of .claude.json — shared, Claude Code offers
#                          to "restore" the personal account into this one
#   policy-limits.json     org policy fetched for the signed-in account
#   remote-settings.json   org-managed settings, same
#   daemon, daemon.log     background-session daemon, which runs as one account
#
# Transcripts (projects/) are shared on purpose: `herd` and `claude --resume`
# read ~/.claude/projects no matter which account wrote the session.
#
# New entries Claude Code adds to ~/.claude later are picked up on the next
# switch. A real file or directory already in the account dir is never
# replaced.
#
# Sourced from BOTH ~/.zshrc and ~/.bashrc — keep it POSIX-compatible.

_CLAUDE_ACCOUNT_OWN=".credentials.json .claude.json backups policy-limits.json remote-settings.json daemon daemon.log"

_claude_link_shared() {
    _shared="$HOME/.claude"
    _dir="$1"
    mkdir -p "$_dir" || return 1
    for _src in "$_shared"/* "$_shared"/.[!.]*; do
        [ -e "$_src" ] || [ -L "$_src" ] || continue
        _name="${_src##*/}"
        case " $_CLAUDE_ACCOUNT_OWN " in *" $_name "*) continue ;; esac
        [ -e "$_dir/$_name" ] || [ -L "$_dir/$_name" ] || ln -s "$_src" "$_dir/$_name"
    done
    unset _shared _dir _src _name
}

# Drop any Foundry routing left by use-*-foundry in this shell, so the
# subscription login is what actually authenticates.
_claude_clear_foundry() {
    export CLAUDE_CODE_USE_FOUNDRY=0
    unset ANTHROPIC_FOUNDRY_BASE_URL ANTHROPIC_FOUNDRY_API_KEY \
          ANTHROPIC_FOUNDRY_RESOURCE AZURE_RESOURCE_NAME \
          ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_HAIKU_MODEL \
          ANTHROPIC_DEFAULT_OPUS_MODEL
}

use-incontext() {
    _claude_link_shared "$HOME/.claude-incontext" || return 1
    _claude_clear_foundry
    export CLAUDE_CONFIG_DIR="$HOME/.claude-incontext"
    echo "Switched to the InContext Claude subscription (~/.claude-incontext)"
    # First run has no login yet: Claude Code opens its sign-in flow — use the
    # InContext Team seat there.
    yolo
}

# Back to the personal subscription in this shell. Doesn't launch anything;
# new shells start here anyway.
use-personal() {
    _claude_clear_foundry
    unset CLAUDE_CONFIG_DIR
    echo "Switched to the personal Claude subscription (~/.claude)"
}
