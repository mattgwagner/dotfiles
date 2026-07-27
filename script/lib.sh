#!/usr/bin/env bash
# Shared helpers for script/bootstrap-*. Source, don't execute.

info ()    { printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
success () { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
fail ()    { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"; exit 1; }

# link_file <src> <dst> — symlink, replacing an existing symlink to the same
# repo, but refusing to clobber a real file/dir that isn't already ours.
link_file () {
  local src=$1 dst=$2
  if [ -L "$dst" ] && [ "$(readlink "$dst")" == "$src" ]; then
    success "already linked: $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    fail "$dst already exists and isn't a link to $src — move it aside and re-run"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  success "linked $src -> $dst"
}

# ensure_sourced <rcfile> <target> — append a guarded `source` line to
# <rcfile> if <target> isn't already sourced from it. Never overwrites
# the rcfile, only appends.
ensure_sourced () {
  local rcfile=$1 target=$2
  touch "$rcfile"
  if grep -qF "$target" "$rcfile" 2>/dev/null; then
    success "$rcfile already sources $(basename "$target")"
    return
  fi
  {
    echo ""
    echo "[ -f \"$target\" ] && source \"$target\""
  } >> "$rcfile"
  success "added source line for $(basename "$target") to $rcfile"
}
