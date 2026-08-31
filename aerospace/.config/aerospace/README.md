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
2. It immediately starts tiling every window on every workspace. There's no
   "enable tiling mode" step like in some other WMs.
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
  `SUPER-f`). Note: this is a per-window tiling-frame resize, not real macOS
  fullscreen -- if the window uses native macOS tabs (e.g. Ghostty), each tab
  is a separate window to AeroSpace, so this state does *not* carry over
  between tabs and you'll see it "reset" when you switch tabs.
- `alt-shift-f` -- real macOS fullscreen (`macos-native-fullscreen`, its own
  Space). Handled entirely by WindowServer, so native-tabbed apps like
  Ghostty switch tabs cleanly here with no tiling to fight over the frame --
  use this one specifically if `alt-f` "jumps" on tab switch.
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

`workspace-to-monitor-force-assignment` pins workspaces 1-5 to the `main`
monitor and 6-9 to `secondary`. Those are AeroSpace's built-in aliases, not
hardware IDs, so the same file works everywhere:

- **Single screen** (this machine): `secondary` doesn't exist, so those
  lines are no-ops -- everything just stays on the one monitor.
- **Two screens** (work): workspaces 6-9 automatically live on the second
  monitor as soon as it's connected. No config change needed either way.

## Work layout: apps auto-route to a monitor

`aerospace.toml` pins a set of recurring apps to a fixed workspace, so they
always land on the same monitor when launched -- no manual dragging:

| Workspace | Monitor   | App                                  |
|-----------|-----------|---------------------------------------|
| 1         | main      | Ghostty                               |
| 2         | main      | Cursor                                |
| 3         | main      | Firefox                               |
| 4         | main      | Zoom -- in-call window (title has "Meeting") |
| 5         | main      | *(free -- Word/Excel/PowerPoint, etc.)* |
| 6         | secondary | Slack                                 |
| 7         | secondary | Outlook                               |
| 8         | secondary | Zoom -- home/start window, everything else |
| 9         | secondary | *(free)*                              |

Office apps (Word/Excel/PowerPoint) are intentionally **not** pinned -- a new
document just opens on whichever workspace you're currently on, and you move
it yourself with `alt-shift-<N>` once it's open. Same for anything else you
want to place case by case.

On this single-monitor machine, workspaces 6-9 still exist and hold Slack/
Outlook/Zoom's home window -- switch to them with `alt-6`..`alt-9` -- they
just share the one screen instead of living on a second monitor.

If an app doesn't route where expected, its bundle id is probably slightly
different than assumed. Check it with:

```bash
osascript -e 'id of app "App Name"'
```

and update the matching `if.app-id` in [aerospace.toml](aerospace.toml). The
Cursor entry in particular is flagged as unverified (todesktop-packaged apps
can vary) -- confirm it on first use.

## Customizing further

- **New floating-window rule**: add another `[[on-window-detected]]` block
  in [aerospace.toml](aerospace.toml). Find an app's bundle id with:
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
