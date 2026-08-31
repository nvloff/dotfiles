# AeroSpace quick-start

A tiling window manager for macOS. Config lives at
[aerospace.toml](aerospace.toml) and is stowed to
`~/.config/aerospace/aerospace.toml`.

## Current state: stock defaults + one customization

This config was reset to AeroSpace's own official `default-config.toml`
(trimmed to 5 workspaces), plus exactly one addition:
`workspace-to-monitor-force-assignment` (workspaces 1-4 on the `main`
monitor, 5 on `secondary`). Everything else -- gaps, keybindings, layout
defaults -- is stock AeroSpace behavior, unmodified.

**Why**: an earlier, much more customized version of this config (app
auto-routing, auto-fullscreen, a floating-by-default rule, Omarchy-matched
keybindings) hit a workspace-switching flicker bug -- switching between
workspaces 1-4 (all on `main`) would rapidly bounce, even with zero windows
open, while workspace 5 (alone on `secondary`) never did. Rather than keep
guessing at which setting caused it, this reset removes every customization
at once so settings can be reintroduced one at a time, testing after each,
to find out what (if anything) actually triggers it.

**If you're picking this back up**: add one setting, reload
(`alt-shift-;` then `esc`), test workspace switching for a bit, then add the
next thing. Worth trying gaps first (purely cosmetic, unlikely to be
involved), then `on-window-detected` rules one at a time, saving anything
that touches fullscreen for last (that's the area most entangled with the
Space/workspace-switching internals that were misbehaving).

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
2. It manages every window immediately -- no "enable" step. Everything
   tiles by default (stock AeroSpace behavior).
3. `start-at-login` is currently `false` (stock default) -- flip it to
   `true` once the config is stable again.

## Keybindings (mod = `alt`) -- stock AeroSpace defaults

- `alt-h/j/k/l` -- focus left/down/up/right
- `alt-shift-h/j/k/l` -- move the focused window
- `alt-minus` / `alt-equal` -- shrink/grow the focused window
- `alt-slash` -- toggle tiles horizontal/vertical
- `alt-comma` -- toggle accordion horizontal/vertical
- `alt-1..5` -- switch to workspace N
- `alt-shift-1..5` -- send the focused window to workspace N (stays on the
  current workspace -- does not follow, unlike some earlier iterations of
  this config)
- `alt-tab` -- jump back to the previous workspace
- `alt-shift-tab` -- send the whole current workspace to the other monitor
- `alt-shift-;` -- enter service mode, then:
  - `esc` -- reload config
  - `r` -- flatten the workspace tree (fix a stuck layout)
  - `f` -- toggle floating/tiling for the focused window
  - `backspace` -- close every window but the current one
  - `alt-shift-h/j/k/l` -- join the focused window with its neighbor

None of this is customized for Omarchy/Hyprland parity right now (that was
part of the previous, more complex version) -- it's plain AeroSpace defaults
until the flicker investigation is done and things get rebuilt deliberately.

## Portability: laptop vs. work desk

`workspace-to-monitor-force-assignment` pins workspaces 1-4 to `main` and 5
to `secondary`. Those are AeroSpace's built-in aliases, not hardware IDs:

- **Single screen** (this machine): `secondary` doesn't exist, so workspace
  5's line is a no-op -- it just stays on the one monitor along with 1-4.
- **Two screens** (work): workspace 5 automatically lives on the second
  monitor as soon as it's connected. No config change needed either way.

## Full command/binding reference

<https://nikitabobko.github.io/AeroSpace/guide>
