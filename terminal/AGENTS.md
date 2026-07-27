# Adding a new project tmux/iTerm session

Two things need to exist for a new project context: a named tmux session on
the mini, and an iTerm Dynamic Profile that opens it. Both are cheap — no
bootstrap re-run required for the common case.

## 1. Pick a session name

Use the project's short slug, e.g. `readerful`, `sittadel`, `redleg-web`.
There's nothing to create in advance — `tmux new -A -s <name>` creates the
session on first use.

## 2. Add an iTerm profile

Edit `iterm/DynamicProfiles/mini-sessions.json` in this repo and append a
new entry to `"Profiles"`:

```json
{
  "Name": "mini: <project>",
  "Guid": "<run `uuidgen`, paste result, never reuse or change it later>",
  "Dynamic Profile Parent Name": "Default",
  "Custom Command": "SSH",
  "Command": "mini",
  "Initial Text": "tmux new -A -s <project>",
  "Close Sessions On End": false,
  "Tags": ["mini"],
  "Badge Text": "<project>"
}
```

`Custom Command: "SSH"` is iTerm's native SSH integration (the same
mechanism the existing "Andy" profile uses) — `Command` is just the SSH
host alias, and `Initial Text` is typed into the shell right after connect.
This is NOT the same as `Custom Command: "Yes"`/`"Custom Shell"` (arbitrary
command / custom shell binary) — those silently fall through to a plain
local shell on this iTerm version instead of erroring, which is what made
the first version of these profiles look broken. Stick to native SSH mode.

Copy the block again with `Command: "mini-remote"` for an away-from-home
variant — see the existing `mini-remote: main` entry. Native SSH profiles
target one host each; there's no `mssh`-style auto-fallback at this layer
(that's what the `mssh` shell function is for — use it directly when you
don't want to keep two profiles per project).

Save the file. iTerm watches `~/Library/Application Support/iTerm2/DynamicProfiles/`
and reloads automatically (that's a symlink to this file — no bootstrap
re-run needed). Open it via Cmd+O and fuzzy-search the project name.

## 3. (Optional) bind a hotkey

For a project you jump into constantly: iTerm Preferences > Profiles >
Keys > check "Show this profile in the hotkey list", then assign a global
shortcut in Preferences > Keys > Hotkey Window.

## Rules

- One profile per project, `Command` always `ssh -t <host> "tmux new -A -s <name>"`.
- `Guid` is permanent once picked — iTerm keys off it, not the name.
- Don't touch `Dynamic Profile Parent Name` — it inherits font/colors/keys
  from the iTerm "Default" profile so you don't have to restate them.
- Commit the change — this file is the source of truth; the copy under
  `~/Library/Application Support/iTerm2/DynamicProfiles/` is a symlink.
