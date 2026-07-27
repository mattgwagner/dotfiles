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
  "Command": "zsh -ic 'mssh <project>; [ $? -ne 0 ] && { echo; echo \"mssh failed — see error above\"; sleep 300; }'",
  "Close Sessions On End": false,
  "Tags": ["mini"],
  "Badge Text": "<project>"
}
```

Routing through `mssh` (not raw `ssh -t`) means the profile inherits its
mini/mini-remote auto-fallback — no separate away-from-home profile needed
per project. `Close Sessions On End: false` + the failure trap keep the tab
open with the error visible instead of silently closing, which is what
made the first version of these profiles look broken. Force a specific
host only if you need to, e.g. `mssh <project> mini-remote`.

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
