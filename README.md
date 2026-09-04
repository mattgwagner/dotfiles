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
| `script/bootstrap-mini` | `~/.tmux.conf` (`terminal/tmux.conf`); tmux plugin manager + resurrect/continuum for reboot survival |

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

### tmux keybindings (`terminal/tmux.conf`)

Prefix is **`Ctrl+a`** (not tmux's factory default `Ctrl+b` — see note below).

| Keys | Action |
|---|---|
| `Ctrl+a` `\|` or `Ctrl+a` `\` | Split horizontally (new pane inherits cwd) |
| `Ctrl+a` `-` | Split vertically (new pane inherits cwd) |
| `Ctrl+a` `c` | New window (inherits cwd) |
| `Ctrl+a` `h`/`j`/`k`/`l` | Move between panes (repeatable — hold prefix, tap again) |
| `Ctrl+a` `s` | Session/window tree picker |
| `Ctrl+a` `N` | Prompt for a new session name |
| `Ctrl+a` `K` | Kill current session (confirms first) |
| `Ctrl+a` `r` | Reload `~/.tmux.conf` |
| `Ctrl+Left` / `Ctrl+Right` | Previous/next window (no prefix) |
| `Alt+←↑↓→` | Resize pane (no prefix) — requires iTerm profile's Option key set to "Esc+", else Alt just types literal characters |

Sessions started via `mssh` survive mini reboots (`tmux-resurrect` +
`tmux-continuum`, auto-restore on).

**If the prefix key seems to do nothing:** this bit us once and the root
cause was never fully pinned down — `Ctrl+b` (tmux's actual factory default)
stopped reaching the terminal on one machine while every other Ctrl
combo (including `Ctrl+c`) worked fine, on both a remote tmux session and a
zero-config local one. The bytes were confirmed reaching the terminal (`cat -v`
echoed `^B` correctly) — tmux itself just never saw them as the prefix.
Switching the prefix to `Ctrl+a` fixed it. If it recurs on a new machine:
confirm you're actually inside a tmux client (`echo $TMUX`), confirm the
live prefix (`tmux show-options -g prefix`), then just try a different
prefix key rather than chasing the root cause further.
