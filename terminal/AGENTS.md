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
  "Custom Command": "Custom Shell",
  "Command": "ssh -t mini \"tmux new -A -s <project>\"",
  "Tags": ["mini"],
  "Badge Text": "<project>"
}
```

Swap `mini` for `mini-remote` (and adjust the Guid/Name/Command) if you want
an away-from-home variant too — see the existing `mini-remote: main` entry
for the pattern.

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
