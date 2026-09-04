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
`zsh/foundry.zsh` (Claude Code Azure Foundry subscription switching),
`zsh/motd.zsh` (startup banner listing the above plus live mini/foundry/herdr
status, shown on every new interactive shell), and — if Herdr is installed —
`terminal/herdr.toml` symlinked to `~/.config/herdr/config.toml`.

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
(`herdr update`) handles the server binary, and `script/bootstrap-shell`
symlinks its config, so the same one command covers both machines.

What each installs:

| Script | Installs |
|---|---|
| `script/bootstrap-shell` | shell environment (`zsh/env.zsh`), aliases (`zsh/aliases.zsh`), Foundry switching (`zsh/foundry.zsh`), startup banner (`zsh/motd.zsh`), `~/.zshrc.local` stub, Herdr config (`terminal/herdr.toml`) |
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

### Herdr config + keybindings (`terminal/herdr.toml`)

Symlinked to `~/.config/herdr/config.toml` by `script/bootstrap-shell`, so
one tracked file covers every machine. Apply an edit without restarting:
`herdr server reload-config` (reports validation diagnostics). Full list of
available settings: `herdr --default-config`. For a machine-specific
override, point `HERDR_CONFIG_PATH` at a different file rather than editing
the tracked one.

Prefix is **`Ctrl+a`**, not Herdr's default `Ctrl+b` — same choice the old
tmux config made, so the muscle memory carries over, and it avoids the
never-root-caused problem (see below) where `Ctrl+b` stopped reaching the
terminal.

| Keys | Action |
|---|---|
| `Ctrl+1`…`Ctrl+9` | Switch tab (no prefix — the closest thing to iTerm's `Cmd+1..9`) |
| `Ctrl+Alt+n` / `Ctrl+Alt+p` | Next / previous tab (no prefix) |
| `Ctrl+a` `v` / `Ctrl+a` `-` | Split vertical / horizontal |
| `Ctrl+a` `h`/`j`/`k`/`l` | Move between panes |
| `Ctrl+a` `c` | New tab |
| `Ctrl+a` `w` | Workspace picker |
| `Ctrl+a` `z` | Zoom pane |
| `Ctrl+a` `q` | Detach |
| `Ctrl+a` `?` | Help — the full live keymap |

**Two things worth knowing about the bindings:**

`Cmd` chords can never reach Herdr. macOS terminals swallow them; they're
never sent to the running program as key bytes. Herdr's own config notes
that `ctrl+letter` and function keys are the reliable direct bindings. This
isn't an iTerm limitation — no terminal fixes it, because iTerm's splits and
Herdr's splits are different objects anyway (an iTerm split gives you a bare
local shell, not a Herdr pane).

`Ctrl+Alt+…` requires iTerm's Left Option key set to **"Esc+"** (Profiles >
Keys). Without it, Alt types literal characters and those bindings are dead.

`ctrl+1..9` uses the `[keys.indexed]` block, which Herdr documents as a
legacy compatibility path — but it's the only documented way to get *direct,
prefix-free* number switching. Revisit if a future Herdr version drops it.

If a binding gets wedged, `herdr config reset-keys` backs up the config and
drops customizations.

### If the prefix key seems to do nothing

Carried forward from the tmux config, because the root cause was never
pinned down and it's a terminal-level problem, not a multiplexer one — it
can bite Herdr the same way.

`Ctrl+b` (tmux's factory default, and Herdr's) once stopped reaching the
terminal on one machine while every other Ctrl combo, including `Ctrl+c`,
worked fine — on both a remote session and a zero-config local one. The
bytes were confirmed arriving at the terminal (`cat -v` echoed `^B`
correctly); the multiplexer just never saw them as the prefix. Switching to
`Ctrl+a` fixed it.

If it recurs: confirm you're actually inside a Herdr client (`echo
$HERDR_ENV`), check the live prefix in `terminal/herdr.toml`, then just try
a different prefix key rather than chasing the root cause further.

### Note on the tmux era

Before Sep 2026 this repo carried a full tmux layer: `terminal/tmux.conf`
(prefix remapped to `Ctrl+a`, tmux-resurrect + tmux-continuum for reboot
survival), `script/bootstrap-mini`, and the `mssh` / `mtux` / `mkill` shell
functions. All of it was removed when Herdr took over. It's recoverable from
git history if Herdr ever disappoints — the last commit that still had it is
the parent of the one that removed it.
