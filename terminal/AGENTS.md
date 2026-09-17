# Terminal setup: Herdr workspaces + iTerm profiles

## Adding a project context — do it in Herdr, not here

Each project is a **Herdr workspace** inside the single persistent session on
the mini. `prefix+shift+n` creates one (it prompts for a name), `prefix+w`
opens the picker, `ctrl+shift+1..9` jumps straight to one.

Nothing in this repo needs to change to add a project. There is no
profile-per-project, no named session to create, no bootstrap re-run. If
you're about to edit `iterm/DynamicProfiles/mini-sessions.json` to add a
project, you're solving it at the wrong layer.

## The iTerm profiles

Two, and there should stay two: `mini: work` (LAN) and `mini-remote: work`
(away). Both SSH to the mini and run `herdr` — that's all they do. Cmd+O,
fuzzy-search "work". The `work` shell function does the same thing with an
automatic LAN-vs-away probe, so the profiles exist mainly for the Cmd+O
muscle memory and an optional hotkey binding.

### Rules for editing the profiles

- **Keep `Custom Command: "SSH"`.** That's iTerm's native SSH integration —
  `Command` is a bare host alias and `Initial Text` is typed into the shell
  after connect, so Herdr runs on the mini. Do **not** switch to
  `Custom Command: "Yes"` (needed to run `herdr --remote` locally): on this
  iTerm version `"Yes"` / `"Custom Shell"` silently falls through to a plain
  local shell instead of erroring, which is what made the first version of
  these profiles look broken. Use the `work` function if you want the
  `--remote` client/server attach.
- **`Guid` is permanent** once picked — iTerm keys off it, not the name.
  `uuidgen` for a genuinely new profile; never reuse or change an existing one.
- **Don't touch `Dynamic Profile Parent Name`** — it inherits font, colors,
  and keys from the iTerm "Default" profile so you don't have to restate them.
- **Set Left Option to "Esc+"** (Preferences > Profiles > Keys) or every
  `ctrl+alt+…` binding in `terminal/herdr.toml` is dead and Alt just types
  literal characters.
- **Commit changes here** — this file is the source of truth; the copy under
  `~/Library/Application Support/iTerm2/DynamicProfiles/` is a symlink created
  by `script/bootstrap-mac`. iTerm watches that directory and reloads live, so
  no restart and no bootstrap re-run is needed.

### Optional: a hotkey

Preferences > Profiles > Keys > "Show this profile in the hotkey list", then
assign a global shortcut under Preferences > Keys > Hotkey Window.

## `herd` — driving the session from inside an agent pane

`terminal/herd` (on PATH as `herd`) is the wrapper agents use to control Herdr.
It exists because the raw `herdr` CLI has three sharp edges worth wrapping once
rather than re-learning per skill:

- `pane run` is silent on success and `pane read` answers in plain text, while
  everything else answers in JSON. `herd` knows which is which.
- `pane wait-output` searches a snapshot that **includes the command line you
  just typed**, so waiting on a literal sentinel matches the echo of your own
  command and returns before anything ran. `herd gate` waits on a marker whose
  shape (`rc=` plus digits) cannot appear in the command text.
- A command that calls `exit` takes the pane's shell down with it, so the
  completion marker never prints and a failure is indistinguishable from a
  hang. `herd gate` runs the command in a subshell.

```bash
herd status                      # every live agent, state, staleness
herd gate <label> -- <cmd...>    # run, wait, exit with its code
herd run  <label> -- <cmd...>    # start and leave running (dev servers)
herd reviewer <name> --kind cursor
herd ask <name> "<prompt>"
herd notify "<title>" --body "<text>" --sound done|request
```

**The cwd invariant.** `herd` opens every pane at `$HOME` and nothing should
change that. Claude project memory is keyed off cwd —
`~/.claude/projects/-home-matt/memory` is a symlink into the vault, shared with
Cursor — so a pane opened anywhere else writes to a store nothing else reads.
This is also why nothing here uses `herdr worktree create`: it forces pane cwd
to `~/.herdr/worktrees/<repo>/<branch>` and ignores `[terminal] new_cwd =
"home"` (verified 2026-09-17). Worktrees are made with plain `git worktree add`
and worked by absolute path.

**`idle` is not `ready`.** Herdr reports an agent sitting at a login prompt as
idle. If `herd ask` returns `agent_prompt_stalled`, `herd read <name>` before
retrying — on this host `codex` is unauthenticated and does exactly that.
