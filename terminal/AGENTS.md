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
