# Dotfiles

See also [https://dotfiles.github.io/]

A personal grab bag of dev tools, references, and helper scripts that I like to have on any development environment I fire up.

## Shell environment (any Mac)

```sh
git clone https://github.com/mattgwagner/dotfiles.git ~/.dotfiles
~/.dotfiles/script/bootstrap-shell
```

Installs `zsh/env.zsh` (Homebrew, nvm, uv, bun, opencode, Docker completions,
iTerm integration), `zsh/aliases.zsh` (`mssh`, `mtux`, `mkill`, `yolo`),
`zsh/foundry.zsh` (Claude Code Azure Foundry subscription switching), and
`zsh/motd.zsh` (startup banner listing the above plus live mini/foundry/tmux
status, shown on every new interactive shell).

Everything in `zsh/env.zsh` is guarded on the target existing, so one file
works on both an Apple Silicon laptop (`/opt/homebrew`) and the Intel mini
(`/usr/local`). Anything added there must avoid hardcoded `/Users/<name>`
paths and unguarded `source` — that combination is what produced login errors
when this config was copied between machines.

Secrets and per-machine values go in `~/.zshrc.local`, which the script
creates as a stub and which is never committed. `use-incontext-foundry` /
`use-sittadel-foundry` read their API keys from there and refuse to switch
if the key is missing.

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
| `script/bootstrap-shell` | shell environment (`zsh/env.zsh`), aliases (`zsh/aliases.zsh`), Foundry switching (`zsh/foundry.zsh`), startup banner (`zsh/motd.zsh`), `~/.zshrc.local` stub |
| `script/bootstrap-mac` | `mssh <session> [host]` shell function (`zsh/aliases.zsh`); iTerm Dynamic Profiles (`iterm/DynamicProfiles/`) |
| `script/bootstrap-mini` | `~/.tmux.conf` (`terminal/tmux.conf`); auto-attach-on-SSH-login (`zsh/ssh-tmux.zsh`); tmux plugin manager + resurrect/continuum for reboot survival |

Both scripts only append guarded `source` lines to `~/.zshrc` and symlink —
they never overwrite an existing file.

Use it via iTerm profile picker (Cmd+O, fuzzy-search "mini: ...") or from any
shell: `mssh <project>`. See [`terminal/AGENTS.md`](terminal/AGENTS.md) for
how to add a new project's session/profile.

To tear one down, `mkill` (no argument) kills the session you're currently in,
which also drops the SSH connection that `mssh` opened — one step back to the
laptop. `mkill <session>` kills a named session from anywhere. Either form
lists any non-shell processes still running in the session and asks before
killing, so an attached Claude Code or dev server isn't dropped by accident.
Note that idle sessions cost almost nothing; this is for reclaiming what's
*running inside* them.
