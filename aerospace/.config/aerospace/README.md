# AeroSpace quick-start

A tiling window manager for macOS. Config lives at
[aerospace.toml](aerospace.toml) and is stowed to
`~/.config/aerospace/aerospace.toml`.

## Install

```bash
brew install --cask nikitabobko/tap/aerospace
```

Then run `install.sh` from the repo root (or `stow aerospace` directly) to
symlink the config.

## First run

1. Launch AeroSpace from Spotlight/Applications. macOS will ask for
   **Accessibility** permission (System Settings → Privacy & Security →
   Accessibility) -- required, since that's how it moves/resizes windows.
2. It manages every window immediately -- no "enable" step. Most things
   float by default here (see "Work layout" below); Firefox is the one
   exception that tiles.
3. `start-at-login = true` is already set in the config, so it survives a
   reboot without extra setup.

## Mental model, coming from AwesomeWM

| AwesomeWM concept        | AeroSpace equivalent                         |
|---------------------------|-----------------------------------------------|
| Tags                      | Workspaces (`workspace 1`..`9`)               |
| `Mod4` (Super)            | `alt` is the mod key here (Cmd is left alone for macOS/app shortcuts) |
| `rc.lua`                  | `aerospace.toml`                              |
| Layouts (tile/max/floating) | `layout tiles`/`accordion`/`floating` per workspace |
| Multi-screen tag placement | `workspace-to-monitor-force-assignment`      |
| Reload config (`Mod+Ctrl+r`) | `alt-shift-;` then `esc` (service mode → reload-config) |

Unlike Awesome, there's no Lua scripting layer -- config is declarative TOML,
and anything dynamic goes through shell commands (`exec-and-forget ...`).

## Keybindings (mod = `alt`)

Bound to match [Omarchy's default Hyprland bindings](https://github.com/basecamp/omarchy/blob/master/default/hypr/bindings/tiling-v2.conf)
key-for-key wherever the two window managers have an equivalent command --
`alt` stands in for Hyprland's `SUPER` throughout (see "Why `alt`, not `cmd`"
below). hjkl is kept alongside arrows since this config predates the Omarchy
work and you're an nvim user.

**Focus / move** -- `hjkl` or arrows, both work
- `alt-h/j/k/l` or `alt-left/down/up/right` -- focus left/down/up/right
- `alt-shift-h/j/k/l` or `alt-shift-left/down/up/right` -- move the focused window
- `alt-shift--` / `alt-shift-=` -- shrink/grow the focused window (Omarchy
  binds this to the bracket keys instead; kept the more common minus/equals
  convention here)

**Layout**
- `alt-slash` -- toggle tiles horizontal/vertical
- `alt-comma` -- toggle accordion horizontal/vertical
- `alt-f` -- fullscreen within the tiling grid (same key as Omarchy's
  `SUPER-f`). This is AeroSpace's own fullscreen, not real macOS fullscreen --
  it stays inside the normal workspace, so `alt-1`..`alt-0` can still
  navigate to it directly. Workspace 2 (Cursor) uses this automatically (see
  "Work layout" below). Caveat: if the window uses native macOS tabs (e.g.
  Ghostty), each tab is a separate window to AeroSpace, so this state does
  *not* carry over between tabs and you'll see it "reset" when you switch
  tabs -- use splits (`alt-enter`) instead of tabs to avoid this.
- `alt-shift-f` -- real macOS fullscreen (`macos-native-fullscreen`, its own
  Space). Handled entirely by WindowServer, so native-tabbed apps switch
  tabs cleanly here with no tiling to fight over the frame -- but it comes
  at a real cost: AeroSpace's workspaces don't control macOS Spaces, so
  `alt-1`..`alt-0` **cannot navigate into a native-fullscreen window** on
  their own -- you'd need Cmd-Tab or Mission Control instead. Workspace 1
  (Ghostty) uses this automatically anyway, paired with an extra trick on
  `alt-1` to route around that limitation -- see "Work layout" below, it's
  marked EXPERIMENTAL there for a reason. Reach for this one manually
  elsewhere only when you specifically need it.
- `alt-t` -- float/tile the focused window (same key as Omarchy's `SUPER-t`)
- `alt-w` -- close the focused window (same key as Omarchy's `SUPER-w`)

**Workspaces**
- `alt-1..9`, `alt-0` for a 10th -- switch to workspace N (same numbers as
  Omarchy's `SUPER-[1-0]`)
- `alt-shift-1..9`/`alt-shift-0` -- send the focused window to workspace N
  and follow it
- `alt-tab` -- jump back to the previous workspace

**Monitors** (only matters when a second screen is attached)
- `alt-cmd-h/l` -- move focus to the monitor left/right
- `ctrl-alt-tab` / `ctrl-alt-shift-tab` -- cycle to the next/previous
  monitor (same chord as Omarchy -- it doesn't use `SUPER` for this either)
- `alt-cmd-shift-h/l` -- send the focused window to the monitor left/right
- `alt-shift-tab` -- send the whole current workspace to the other monitor

**Other**
- `alt-enter` -- open a new Ghostty window
- `alt-shift-;` -- enter service mode, then:
  - `esc` -- reload config
  - `r` -- flatten the workspace tree (fix a stuck layout)
  - `backspace` -- close every window but the current one

**No AeroSpace equivalent, left out rather than faked**: Hyprland's window
grouping (`SUPER-g`, tabs multiple windows into one slot) and scratchpad
(`SUPER-s`, a special always-on-top floating workspace) -- AeroSpace has no
matching concept for either.

### Why `alt`, not `cmd`

Omarchy's mod key is `SUPER` -- physically the same key as macOS's `Cmd`.
Binding the WM to `cmd` directly would be the literal match, but `Cmd` is
already claimed everywhere by app shortcuts (`Cmd-w` closes a tab in every
browser, `Cmd-1..9` switches tabs, `Cmd-t` opens one, etc.) -- rebinding
those at the WM level would fight your apps constantly. `alt` avoids that
collision entirely, at the cost of the mod key itself not matching. Every
other key in this file is chosen to match Omarchy exactly, so the muscle
memory difference is just "which modifier," not "which key."

## Portability: laptop vs. work desk

`workspace-to-monitor-force-assignment` pins workspaces 1-4 to `main` and 5
to `secondary`. Those are AeroSpace's built-in aliases, not hardware IDs, so
the same file works everywhere:

- **Single screen** (this machine): `secondary` doesn't exist, so workspace
  5's line is a no-op -- it just stays on the one monitor along with 1-4.
- **Two screens** (work): workspace 5 automatically lives on the second
  monitor as soon as it's connected. No config change needed either way.

## Work layout

| Workspace | Monitor   | Contents                                        |
|-----------|-----------|--------------------------------------------------|
| 1         | main      | Ghostty -- always real macOS fullscreen (EXPERIMENTAL, see below) |
| 2         | main      | Cursor -- always fullscreen (AeroSpace's own)     |
| 3         | main      | Firefox -- normal tiling, can still split w/ another window |
| 4         | main      | Everything else -- floats, close to plain macOS window management |
| 5         | secondary | Everything else -- same, floating, second monitor |

**Workspace 1 (Ghostty) is a live experiment.** It uses real
`macos-native-fullscreen`, which normally makes `alt-1` unable to reach it at
all (AeroSpace's workspaces don't control macOS Spaces -- see the
keybindings section above). To route around that, `alt-1` additionally runs
`open -b com.mitchellh.ghostty`, leaning on a real, documented macOS
mechanism: System Settings -> Desktop & Dock -> Mission Control -> "**Switch
to a Space with open windows for the application**" -- when that's on
(Apple's default), activating an app by *any* means, including `open -b`,
switches you to its fullscreen Space, the same way Cmd-Tab already does for
you. **What's unverified**: chaining that specifically onto an AeroSpace
keybind to solve this exact problem isn't a known recipe from anyone else --
it's built from how the two mechanisms are documented to work individually.
If `alt-1` stops reliably reaching Ghostty, check that Mission Control
setting first; if it's on and this still doesn't work, revert Ghostty's
`on-window-detected` rule to `fullscreen on` (AeroSpace's own, like
workspace 2) and drop the `exec-and-forget` half of `alt-1`.

**Workspace 2 (Cursor) intentionally was NOT switched to native fullscreen.**
Cursor is Electron-based, and separately hits a real, currently-unfixed
AeroSpace bug: Chromium/Electron apps periodically call a macOS API in the
background that fights AeroSpace's workspace-hiding mechanism, causing
`alt-2` to flicker/bounce and land on an empty desktop instead of Cursor.
This happens regardless of native vs. AeroSpace fullscreen -- confirmed by
testing -- so switching Cursor to native fullscreen would add complexity
with no possible upside. Cmd-Tab remains the reliable way to reach Cursor;
there is no known AeroSpace-side fix for this as of AeroSpace 0.21.3-Beta.

Slack/Outlook/Zoom/Office apps are deliberately **not** pinned anymore -- open them
wherever's convenient (usually 4 or 5) and they'll float there automatically;
move anything with `alt-shift-<N>` if you want it somewhere else.

Workspaces 6-10 still exist and are bound (`alt-6`..`alt-0`, matching
Omarchy's `SUPER-[1-0]`) but aren't part of the active layout -- plain
scratch space, not persistent, no monitor assignment.

**Floating is the actual default now, tiling is the exception.** AeroSpace
has no "this workspace defaults to floating" setting (`default-root-
container-layout` only takes `tiles|accordion` -- that's the arrangement of
windows that are already tiling, not a floating/tiling switch). So instead
[aerospace.toml](aerospace.toml)'s first `on-window-detected` rule floats
*every* window unconditionally, and only Firefox gets explicitly pulled back
into tiling afterward -- this is AeroSpace's own documented pattern for
exactly this situation, not a workaround. Workspaces 4/5 don't need any
rule of their own; they just inherit the default.

If an app doesn't route where expected (workspaces 1-3), its bundle id is
probably slightly different than assumed. Check it with:

```bash
osascript -e 'id of app "App Name"'
```

and update the matching `if = 'test %{app-bundle-id} = ...'` line in
[aerospace.toml](aerospace.toml). The Cursor entry in particular is flagged
as unverified (todesktop-packaged apps can vary) -- confirm it on first use.

## Customizing further

- **New app that should tile instead of float**: add another
  `[[on-window-detected]]` block after the blanket floating rule in
  [aerospace.toml](aerospace.toml), following the Firefox one as a template
  (`run = [..., 'layout tiling']`). Find an app's bundle id with:
  ```bash
  osascript -e 'id of app "Finder"'
  ```
- **Focus-follows-mouse / window borders**: AeroSpace intentionally doesn't
  draw a focus border. If you want one, install
  [JankyBorders](https://github.com/FelixKratz/JankyBorders)
  (`brew install borders`) and start it from `after-startup-command` in the
  config -- not included here so the base config has zero extra
  dependencies.
- **Full command/binding reference**:
  <https://nikitabobko.github.io/AeroSpace/guide>
