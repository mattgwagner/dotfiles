# Dotfiles

See also [https://dotfiles.github.io/]

A personal grab bag of dev tools, references, and helper scripts that I like to have on any development environment I fire up.

## tmux + iTerm remote sessions (mini / mini-remote)

Persistent, resumable named sessions on the Mac mini, reachable from iTerm on
the Mac without retyping SSH/tmux commands. Assumes `mini` and `mini-remote`
host aliases already exist in `~/.ssh/config` (local mDNS vs external IP).

Install:

```sh
git clone https://github.com/mattgwagner/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# On your Mac (laptop/desktop):
script/bootstrap-mac

# On the mini itself (ssh mini, or run locally if you're on it):
script/bootstrap-mini
```

What each installs:

| Script | Installs |
|---|---|
| `script/bootstrap-mac` | `mssh <session> [host]` shell function (`zsh/aliases.zsh`); iTerm Dynamic Profiles (`iterm/DynamicProfiles/`) |
| `script/bootstrap-mini` | `~/.tmux.conf` (`terminal/tmux.conf`); auto-attach-on-SSH-login (`zsh/ssh-tmux.zsh`); tmux plugin manager + resurrect/continuum for reboot survival |

Both scripts only append guarded `source` lines to `~/.zshrc` and symlink —
they never overwrite an existing file.

Use it via iTerm profile picker (Cmd+O, fuzzy-search "mini: ...") or from any
shell: `mssh <project>`. See [`terminal/AGENTS.md`](terminal/AGENTS.md) for
how to add a new project's session/profile.
