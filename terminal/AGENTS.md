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
herd adopt <name> --brief            # fold in a child herd did not start (gsd --foundry)
herd inbox                           # this pane's children; ! needs you, * unread
herd inbox --all                     # every outstanding child on the box
herd inbox --all --read              # ...including the ones already collected
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

**One file per child, carrying all three messages.** A child has three things to
say — that it is alive, what it found, and what it needs — and only one channel
that crosses. So they share it. The brief has the child stamp `status:` lines as
it goes, replace the file with its result when it finishes, and end on a
`## BLOCKED:` line if it has to stop and ask. `herd inbox` tells those apart by
reading the file:

```
 ! gsd-781   blocked    3m  Cap the backfill at 5 or 50?      <- needs an answer
 * gsd-782   exited    12m  Shipped b7745ba: fit-score now…   <- unread result
 x gsd-783   exited    41m  started — reading the issue       <- died mid-flight
 - gsd-785   working    1m  worktree up, tests green          <- alive, progressing
```

That `x` row is the one that did not exist before: a child that went down
without reporting used to be indistinguishable from one still working, because
the file stayed empty either way. The age column is time since the child last
wrote — a heartbeat, not a runtime — so a `-` row that has not moved in an hour
is a wedged agent, and says so.

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

**A question does not look like a question, and a toast does not reach the
driver.** Herdr classifies `blocked` from an approval or question *UI*. A child
that ends its turn with prose asking something reads as plain `idle` —
indistinguishable from twenty children that are simply done. So the brief asks
for two things, because they land in two different places: `herdr notification
show … --sound request` reaches **Matt at his desk**, and a `## BLOCKED:` last
line reaches **the driver**, which is the only one that can re-dispatch. There
is no third option — `herdr notification` is show-only, no list and no read
verb (verified 2026-09-18 on 0.9.1), so nothing a child raises as a toast can
ever be polled. `done` (unseen-idle, `*` in `herd status`) is the real
completion signal; `idle` is not.

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
- Report files are **rewritten** on spawn, with a dispatch stamp. Deleted,
  because a stale report from a previous run of the same name would read as
  this run's answer the moment `herd inbox` looked. Stamped, because an absent
  file and an idle child used to look identical in the list.
- **`--all` lists what is outstanding, not everything ever written.** A
  collected report is finished business, and the reports directory is
  append-only — 80 of them buried the 15 rows that still wanted something the
  first time it ran. They are hidden under `--all` and counted in the footer,
  so the view never lies about what it is not showing; `--read` brings them
  back. A `!` row is never hidden: reading a question does not answer it. The
  pane-scoped list stays whole, because it is small and a read sibling is
  context.
- **`herd inbox` is one inbox, not one per pane.** What has been read is
  recorded once in `~/.cache/herd/seen.json`; `--all` reads the reports
  directory rather than the dispatching pane's registry, so a child outlives
  the driver that sent it. Before this, a driver pane dying orphaned its
  children silently — 31 empty registries and 9 uncollected reports on the
  first heavy day.
- **`herd adopt <name>`** folds in a child `herd spawn` could not start:
  a `gsd --foundry` tab (`--spawn` and `--foundry` are mutually exclusive), or
  one whose driver pane is gone. `--brief` also hands it the reporting contract
  it never got — queued, so it applies to the turn it is already in. It does
  not claim the child's tab unless you pass `--own-tab`; a tab this pane did
  not open is not its to close.

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

## Browsers on this box

There are **three** browser paths available from omarchy. Two run here and need
no Mac; one drives Matt's MacBook. Pick by the job, not by habit.

Verified 2026-09-22. The old assumption — "the only browser is the one on the
Mac, reached over the tailnet" — is no longer true, and
`~/.claude/hooks/browser-localhost-guard.sh` was rewritten to say so.

### Which path for which job

| Job | Use | Why |
|---|---|---|
| Run e2e specs | Playwright (`npm run test:e2e`) | Already a devDependency; asserts, retries, fixtures |
| Read/click a page, judge copy, check a flow | `agent-browser` | Text out, no display, localhost works, real clicks |
| Need Matt's logged-in Chrome, or a human watching | claude-in-chrome + tailnet | Only path with his profile/cookies |

**Default to `agent-browser` for exploratory verification.** It is the one that
replaces "load this page and read it cold".

### Path 1 — Playwright (the test path)

Already installed per-repo. The browser binaries are versioned separately from
the npm package, so after a Playwright bump the cache goes stale and every spec
fails with `Executable doesn't exist at .../chromium_headless_shell-<N>`. That
is not a broken test:

```bash
npm run test:e2e:install     # downloads the matching build (~300MB, ~2min)
npm run test:e2e             # boots its own dev server via playwright.config.ts
```

Do **not** add `--with-deps`. It has hung for 25-35 minutes with zero output
(see `~/vault/Resources/Tooling Gotchas/Lessons.md`). Plain `install` is fine
here — Arch already has the shared libraries, despite Playwright warning that
the OS is "not officially supported" and pulling an ubuntu24.04 fallback build.

If a dev server is already up, skip the managed one:
`E2E_SKIP_WEBSERVER=1 npx playwright test`.

### Path 2 — agent-browser (the exploratory path)

A terminal-first CLI built for agents: compact **text** output instead of
screenshots, so it is cheap on context. Headless, no display server needed.

```bash
npm install -g --allow-scripts=agent-browser agent-browser
agent-browser install          # fetches its own Chrome into ~/.agent-browser
```

The `--allow-scripts` flag is required — npm here blocks postinstall by default,
and a plain `npm install -g agent-browser` silently leaves it unable to launch.

```bash
agent-browser read http://localhost:3000/          # page as readable prose
agent-browser snapshot                             # a11y tree with @refs
agent-browser open  http://localhost:3000/login
agent-browser fill  @e5 'you@example.com'
agent-browser click @e4
agent-browser get url
agent-browser close --all                          # always, when done
```

**Selectors:** CSS works, but Playwright-isms do not — `button:has-text("...")`
returns "Element not found". Run `snapshot`, then act on the `@eN` refs. That is
the intended flow and it is more stable than guessing selectors.

`agent-browser skills get core --full` prints the full command reference.

**Screenshots, and how an agent actually sees them:**

```bash
agent-browser screenshot /tmp/shot.png
```

then open it with the **Read tool**, which renders PNGs into the transcript.
Writing a file to disk is not verification — an agent that only reports "the
screenshot was saved" has checked nothing. Read it back and say what is on it.

**What text cannot tell you.** `read` flattens layout: nav items run together
("ProductPricingWays to work"), and spacing, contrast and overlap are invisible.
On a real check, `snapshot` caught that a button was *enabled* while the
screenshot showed it rendered grey enough to read as disabled. Neither view
alone was right. **For a UX judgement, take the screenshot too.**

### Path 3 — headed Chromium on the Hyprland session

Hyprland runs on seat0/tty1 and its socket is `/run/user/1000/wayland-1`. Agent
shells land in a tty context with no `WAYLAND_DISPLAY`, which makes the box look
headless; it is not. To attach a real window:

```bash
export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1
setsid chromium --ozone-platform=wayland --user-data-dir=/tmp/prof <url> &
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr | head -1)
hyprctl clients        # confirm the window exists
```

**Check whether anyone can see it first:**

```bash
hyprctl monitors | head -3        # "Monitor FALLBACK" = virtual output
for c in /sys/class/drm/card*-*/status; do echo "$c $(cat $c)"; done
```

As of 2026-09-22 every DRM connector reads `disconnected` and Hyprland is on a
FALLBACK output — **no physical screen is attached**, so a headed window renders
where nobody is looking and buys nothing over headless. Re-check rather than
assume; if a monitor is plugged in this becomes the path where Matt can watch.

Two standing costs regardless: it depends on the graphical session (if Hyprland
dies, so does your browser), and a window popping up unannounced is intrusive
if Matt is at the machine. **Prefer headless unless a human is actually
watching.**

### Path 4 — claude-in-chrome (the MacBook, unchanged)

`mcp__claude-in-chrome__*` drives Chrome on Matt's MacBook, not this box. It is
still the right tool when you need his logged-in profile or his eyes on the
page. `localhost` there means *the Mac's* localhost — the guard hook denies it
and hands back both the local commands and the tailnet URL.

```bash
tailscale serve --bg 3000
# https://omarchy.tailacf9b6.ts.net/...    (undo: tailscale serve reset)
```

Next.js dev also needs the tailnet origin in `allowedDevOrigins`
(`NEXT_DEV_ORIGINS` in `.env.local`) or the page renders but never hydrates.

### Cleaning up

Leaving browsers running is the norm failure here — a stray Playwright
`chrome-headless-shell` from an inline node script was found still alive after
**8 days**, its parent long gone.

```bash
agent-browser close --all
ps -eo pid,etimes,args | awk '/chrom/ && !/type=/'   # inspect before killing
```

Kill strays **by PID**. Never `pkill -f chrom` — the pattern matches your own
command line and the agent harness's `claude --chrome` processes.
