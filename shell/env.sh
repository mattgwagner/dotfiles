# Portable shell environment — safe to source on any Mac.
#
# Everything here is guarded on the thing actually existing, so the same file
# works on an Apple Silicon laptop (/opt/homebrew, user `matt`), the Intel
# Mac mini (/usr/local, user `mattwagner`), and the Omarchy/Arch agent host
# (no Homebrew, mise instead of nvm, bash instead of zsh) without erroring.
#
# Sourced from BOTH ~/.zshrc (Macs) and ~/.bashrc (Omarchy), so everything
# here must be POSIX-compatible. Shell-specific bits go behind a
# $ZSH_VERSION / $BASH_VERSION guard.
#
# Rule for anything added here: no hardcoded /Users/<name> paths, and no
# unguarded `source`. Machine-specific values and secrets belong in
# ~/.zshrc.local, which is sourced last and never committed.

# --- Homebrew ---------------------------------------------------------------
# Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [ -x "$_brew" ] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# --- nvm --------------------------------------------------------------------
# Both the standalone installer (~/.nvm) and the brew formula. Note that
# `brew --prefix nvm` prints a path even when the formula isn't installed,
# so test for nvm.sh itself rather than trusting the prefix.
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -n "$HOMEBREW_PREFIX" ] && [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] \
  && source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"

# --- uv ---------------------------------------------------------------------
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# --- bun --------------------------------------------------------------------
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# --- mise -------------------------------------------------------------------
# The Omarchy host manages node/go/etc through mise rather than nvm. Activating
# per-shell gives real binaries on PATH instead of only the shims, which
# matters for anything resolving tools via `command -v`.
if command -v mise >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(mise activate zsh)"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(mise activate bash)"
  fi
fi

# --- opencode ---------------------------------------------------------------
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# --- Docker CLI completions -------------------------------------------------
# zsh-only: fpath and compinit have no bash equivalent. Bash gets Docker
# completion from its own /usr/share/bash-completion drop-ins.
if [ -n "$ZSH_VERSION" ]; then
  if [ -d "$HOME/.docker/completions" ]; then
    fpath=("$HOME/.docker/completions" $fpath)
  fi
  autoload -Uz compinit
  compinit
fi

# --- iTerm2 shell integration (macOS + zsh only) ----------------------------
[ -n "$ZSH_VERSION" ] && [ -f "$HOME/.iterm2_shell_integration.zsh" ] \
  && source "$HOME/.iterm2_shell_integration.zsh"
