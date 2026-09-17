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
herd reviewer <name> --kind cursor --task-file <f>   # reports back like spawn
herd ask <name> "<prompt>"       # steer a running agent; cannot read findings
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

## The driver pattern — one thread that dispatches, many that work

The shape Matt actually wants: **one pane he talks to, which farms items out and
watches them**, instead of opening a tab per item by hand.

```bash
herd spawn <name> --task "<brief>"   # child agent in its OWN TAB, fire-and-forget
herd inbox                           # who reported back; * = unread
herd inbox <name>                    # read one report in full
herd status --stale 60               # every agent everywhere, not just mine
herd close --all                     # sweep every pane and child this pane opened
gsd --spawn <url>                    # a ticket straight into its own tab
```

Four rules make it hold. Each one is a failure that already happened.

**Spawn tabs, never splits.** `pane split` carves the new pane out of the
caller, so a driver that dispatches six children is 1/2^6 of the rectangle it
started in — that is how a driver ends up asking a question in a box too narrow
to show the question. `herd spawn` creates a *tab*, so the driver's geometry
never changes. Measured: 215x75 before a spawn, 215x75 after spawning,
dispatching, reading and closing. `herd run`/`gate`/`reviewer` still split, and
should — they are for a command or a reviewer beside the work, not a herd.

**The driver never waits.** `herd spawn` prompts without `--wait` on purpose. A
driver blocked on a ten-minute child cannot take the next thing Matt says, which
is the entire thing the pattern was supposed to buy. Poll with `herd inbox`.

**Results come back as files.** Agent TUIs paint on the terminal's alternate
screen, so `agent read` returns the tool-call rail plus "… N output lines
hidden" and raising `--lines` recovers nothing. `herd spawn` appends a reporting
contract to every brief: write Markdown to `~/.cache/herd/reports/<name>.md`,
headline on line one, reply with the path. `herd inbox` reads the files.

This is a property of agent TUIs, not of tabs, so `herd reviewer` given a
`--task`/`--task-file` carries the same contract into its sibling pane and
lands in the same `herd inbox`. Do not hand-roll a scratch path for a verdict,
and do not reach for `herd ask` to collect one: `ask` ends in the very
`agent read` that cannot see it. `ask` is for *steering* an agent you are
watching; a brief is for getting something back.

**A question does not look like a question.** Herdr classifies `blocked` from an
approval or question *UI*. A child that ends its turn with prose asking
something reads as plain `idle` — indistinguishable from twenty children that
are simply done. The brief therefore tells it to raise
`herdr notification show … --sound request`. `done` (unseen-idle, `*` in `herd
status`) is the real completion signal; `idle` is not.

### Spawn gotchas, verified 2026-09-17

- A freshly spawned `claude` opens on the **trust-this-folder dialog**:
  `agent start` returns `agent_not_ready` and the child parks there looking like
  a hung launch. `herd spawn` answers that one dialog by its option text and
  refuses to guess at any other blocked UI — an unrecognised one is left open,
  because the pane is the evidence.
- A just-started agent **lies about being ready**. It reports `idle` with
  `interactive_ready: true` while the TUI is still painting; the paste lands
  nowhere and `agent prompt` burns its five-second lifecycle budget and returns
  `agent_prompt_stalled`. The first attempt after the trust dialog fails and the
  second lands, so `herd spawn` retries three times with a 3s settle.
- Report files are deleted on spawn. A stale report from a previous run of the
  same name would read as this run's answer the moment `herd inbox` looked.

### Which harness gets the work — dispatch against the quota you have

A dispatch decision is a spend decision. Claude subagents and Claude tabs draw
on the **same session quota as the driver**, so a driver that fans out five
Claude children is racing its own conversation to the limit — and the driver
hitting a wall mid-run is worse than any single child being slower, because
nothing is left to collect the reports or resolve a push conflict.

Route by what the work needs, then by what it costs:

| Route | Command | Use it for |
|---|---|---|
| Subagent, same session | `Agent` tool | Fan-out **reads** where only the conclusion matters. No pane, no tab. |
| Claude tab | `gsd --spawn <url>` | Work that needs Claude's judgement — ambiguous scope, a design call, a surface you have to reason about. |
| **Cursor tab** | `gsd --spawn --cursor <url>` | Everything else, and **the default once the Claude session is in sight of its limit.** Same `get-shit-done` skill, different quota. |
| Foundry | `gsd --foundry <url>` | InContext work, so it bills to their subscription. Cannot be `--spawn`ed. |

Rules that hold regardless of route:

- **Check the balance before the second wave, not after.** The moment you are
  dispatching a *batch*, ask which harness each item needs. Handing all of it to
  Claude because the first one went there is how the session ends mid-flight.
- **Never re-route work that is already in flight.** Killing a child to move it
  to a cheaper harness throws away the expensive part — the worktree, the
  reading, the half-written diff. Let it finish and send the *next* item
  elsewhere.
- **Give every child the collision map.** Parallel gsd children share one repo.
  Each brief names the other children's surfaces, the files they share, and the
  house rules: plain `git worktree add`, `git pull --rebase` before start and
  before every push, stage by path (never `-A`), never `git reset --hard`, never
  `tailscale serve reset` (host-global — it kills the other children's browser
  verification).
- **Sequence, don't just parallelise.** Two items that edit the same prompt or
  the same test file are not two dispatches, they are one queue. Hold the second
  until the first lands, especially when it should be written *against* the
  first one's behaviour.

### Context, not just panes

The driver's context window is the bottleneck, not the pane count. It should
read headlines and decisions, never transcripts — that is why the contract asks
for a one-sentence first line. And this pattern is for **long-lived per-project
work you will come back to**. For fan-out reads where you only want a
conclusion, subagents inside one session are strictly better and cost no panes.

### From the MacBook

`work [host]` attaches to the same persistent session over SSH, so you are in a
real pane on the agent host and **every verb above works unchanged**. That is
the supported answer, not an ssh shim.

`herd --machine <label>` runs a one-shot against a saved machine without
attaching, but only the observe/steer verbs: `status`, `read`, `ask`, `notify`,
`close`. `spawn` and `inbox` are refused there by design — both resolve paths
(`--cwd`, the report file) against *this* host's home, so from a MacBook the
brief would tell the child to write to `/Users/mattwagner/...` for work running
on omarchy, and the driver would watch a path nothing ever writes. Saved
machines are registered on the client side with `herdr machine add <ssh-target>
--label <label>`.
