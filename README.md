# Dotfiles

See also [https://dotfiles.github.io/]

A personal grab bag of dev tools, references, and helper scripts that I like to have on any development environment I fire up.

## Shell environment (any Mac)

```sh
git clone https://github.com/mattgwagner/dotfiles.git ~/.dotfiles
~/.dotfiles/script/bootstrap-shell
```

Installs `zsh/env.zsh` (Homebrew, nvm, uv, bun, opencode, Docker completions,
iTerm integration), `zsh/aliases.zsh` (`hmini`, `hls`, `hkill`, `yolo`),
`zsh/foundry.zsh` (Claude Code Azure Foundry subscription switching), and
`zsh/motd.zsh` (startup banner listing the above plus live mini/foundry/herdr
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

## Herdr + iTerm remote sessions (mini / mini-remote)

Persistent, resumable named sessions on the Mac mini, reachable from iTerm on
the Mac without retyping SSH commands. Sessions are managed by
[Herdr](https://herdr.dev) — a terminal workspace manager built for coding
agents, which replaced tmux here in Sep 2026. Assumes `mini` and `mini-remote`
host aliases already exist in `~/.ssh/config` (local mDNS vs external IP), and
that Herdr is installed on the mini.

Install:

```sh
git clone https://github.com/mattgwagner/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# On your Mac (laptop/desktop):
script/bootstrap-mac
```

There is no longer a mini-side bootstrap script — Herdr's own installer
(`herdr update`) handles the server, and its config lives in
`~/.config/herdr/config.toml` on the mini, not in this repo.

What each installs:

| Script | Installs |
|---|---|
| `script/bootstrap-shell` | shell environment (`zsh/env.zsh`), aliases (`zsh/aliases.zsh`), Foundry switching (`zsh/foundry.zsh`), startup banner (`zsh/motd.zsh`), `~/.zshrc.local` stub |
| `script/bootstrap-mac` | `hmini` / `hls` / `hkill` shell functions (`zsh/aliases.zsh`); iTerm Dynamic Profiles (`iterm/DynamicProfiles/`) |

Both scripts only append guarded `source` lines to `~/.zshrc` and symlink —
they never overwrite an existing file.

Use it via the iTerm profile picker (Cmd+O, fuzzy-search "mini: ...") or from
any shell:

| Command | Action |
|---|---|
| `hmini` | Attach to the default Herdr session on the mini |
| `hmini <session>` | Attach to / create a named session; auto-picks `mini` (LAN) or `mini-remote` (away) |
| `hmini <session> mini-remote` | Force a host, skipping the reachability probe |
| `hls [host]` | List the mini's Herdr sessions (`herdr session list` over SSH) |
| `hkill <session> [host]` | Stop a named session — confirms first, since it kills what's running inside |

`hmini` uses Herdr's `--remote` client/server attach; the iTerm profiles
instead SSH in and run `herdr --session main` on the mini (see
[`terminal/AGENTS.md`](terminal/AGENTS.md) for why, and for how to add a new
project's session/profile).

Idle sessions cost almost nothing — `hkill` is for reclaiming what's *running
inside* one, not for tidying up the list.

### Keybindings

Herdr's keybindings are its own, configured in `~/.config/herdr/config.toml`
on whichever machine runs the client — not in this repo. See
<https://herdr.dev> or `herdr --help`. `herdr config reset-keys` backs up the
config and drops any customizations if a binding gets wedged.

### Note on the tmux era

Before Sep 2026 this repo carried a full tmux layer: `terminal/tmux.conf`
(prefix remapped to `Ctrl+a`, tmux-resurrect + tmux-continuum for reboot
survival), `script/bootstrap-mini`, and the `mssh` / `mtux` / `mkill` shell
functions. All of it was removed when Herdr took over. It's recoverable from
git history if Herdr ever disappoints — the last commit that still had it is
the parent of the one that removed it.
