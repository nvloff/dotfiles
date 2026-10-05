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
2. It manages every window immediately -- no "enable" step.
3. **Check for keyboard shortcut conflicts first**: System Settings →
   Keyboard → Keyboard Shortcuts → Mission Control. If any "Switch to
   Desktop N" entries are bound to `alt+1` through `alt+6` (or whatever
   AeroSpace uses on this machine), remove them. A previous version of this
   setup hit a confusing workspace-switch flicker (switch to N, briefly
   bounce back to the previous workspace, then settle on N) that took a long
   investigation to trace back to exactly this: macOS's own native
   Space-switch shortcut and AeroSpace's binding firing on the same keypress
   and fighting each other. It was never an AeroSpace or config bug.
4. `start-at-login` is currently `false` (stock default) -- flip it to
   `true` once you're happy with the config.

## Keybindings (mod = `alt`) -- stock AeroSpace defaults

Deliberately kept close to AeroSpace's own `default-config.toml` rather than
customized -- simple and easy to reason about. No Omarchy/Hyprland-parity
keybindings or extra monitor-cycling chords right now; add them back
individually if wanted later.

- `alt-h/j/k/l` -- focus left/down/up/right
- `alt-shift-h/j/k/l` -- move the focused window
- `alt-minus` / `alt-equal` -- shrink/grow the focused window
- `alt-slash` -- toggle tiles horizontal/vertical
- `alt-comma` -- toggle accordion horizontal/vertical
- `alt-1..6` -- switch to workspace N
- `alt-shift-1..6` -- send the focused window to workspace N (does not
  follow -- you stay on the current workspace)
- `alt-tab` -- jump back to the previous workspace
- `alt-shift-tab` -- send the whole current workspace to the other monitor
- `alt-shift-;` -- enter service mode, then:
  - `esc` -- reload config
  - `r` -- flatten the workspace tree (fix a stuck layout)
  - `f` -- toggle floating/tiling for the focused window
  - `backspace` -- close every window but the current one
  - `alt-shift-h/j/k/l` -- join the focused window with its neighbor

## Portability: laptop vs. work desk

`workspace-to-monitor-force-assignment` pins workspaces 1-4 to `main` and 5-6
to `secondary`. Those are AeroSpace's built-in aliases, not hardware IDs:

- **Single screen** (this machine): `secondary` doesn't exist, so workspace
  5/6's lines are no-ops -- they just stay on the one monitor along with 1-4.
- **Two screens** (work): workspaces 5-6 automatically live on the second
  monitor as soon as it's connected. No config change needed either way.

## Work layout

| Workspace | Monitor   | Contents                                        |
|-----------|-----------|--------------------------------------------------|
| 1         | main      | Ghostty -- always fullscreen (AeroSpace's own)    |
| 2         | main      | Everything else -- floats, close to plain macOS window management |
| 3         | main      | Firefox -- the one exception, tiled, can split w/ another window |
| 4         | main      | Everything else -- same                           |
| 5         | secondary | Everything else -- same, floating, second monitor |
| 6         | secondary | Outlook -- floating, second monitor               |

**Floating is the actual default, tiling is the exception.** AeroSpace has
no "this workspace defaults to floating" setting (`default-root-container-
layout` only takes `tiles|accordion` -- that's the arrangement of windows
already tiling, not a floating/tiling switch). So instead
[aerospace.toml](aerospace.toml)'s first `on-window-detected` rule floats
*every* window unconditionally, and Ghostty/Firefox/Outlook get pulled out
into their specific treatment afterward -- this is AeroSpace's own
documented pattern for exactly this situation, not a workaround. Workspaces
2/4/5 don't need any rule of their own; they just inherit the default.

**Fullscreen uses `fullscreen on` (AeroSpace's own), not
`macos-native-fullscreen`, on purpose.** Native fullscreen creates a real
macOS Space that AeroSpace's own workspace-switching can't navigate into --
`alt-1` would silently stop reaching those windows. AeroSpace's own
fullscreen stays inside the normal workspace, so direct addressing always
works, at one small cost: if you use Ghostty's *native macOS tabs*
specifically, each tab is a separate window to AeroSpace, and this
fullscreen state doesn't carry over between tabs -- you'd see it visually
reset when switching tabs. Use splits (`cmd-enter` in this Ghostty config) or
a terminal multiplexer instead of native tabs there and this never comes up.

Outlook is the only communication app pinned (workspace 6). Slack/Zoom/other
Office apps are deliberately **not** pinned -- open them wherever's
convenient (usually 2, 4 or 5) and they'll float there like everything else. Move anything with `alt-shift-<N>`.

If an app doesn't route where expected (workspaces 1, 3, 6), its bundle id is
probably slightly different than assumed. Check it with:

```bash
osascript -e 'id of app "App Name"'
```

and update the matching `if = 'test %{app-bundle-id} = ...'` line in
[aerospace.toml](aerospace.toml).

## Customizing further

- **New app that should tile instead of float**: add another
  `[[on-window-detected]]` block after the blanket floating rule in
  [aerospace.toml](aerospace.toml), following the Firefox one as a template
  (`run = [..., 'layout tiling']`).
- **Full command/binding reference**:
  <https://nikitabobko.github.io/AeroSpace/guide>
