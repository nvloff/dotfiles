---
name: nvim-plugin-audit
description: Update this Neovim config's plugins (vim.pack) and re-validate each is still the right choice. Triggers: "update/upgrade my nvim plugins", "audit my nvim config", "are my plugins still maintained/relevant", "revalidate my neovim setup". Not for one-off init.lua edits unrelated to plugins (keymaps, options) -- normal edits per AGENTS.md.
---

# Neovim plugin audit

Config: `~/.config/nvim`, a stow symlink to `<repo>/nvim/.config/nvim`. Resolve with `readlink -f ~/.config/nvim`, run every command below from there. Plugin manager: `vim.pack`.

**Manual, user-triggered only.** Never automate/schedule -- step 4's judgment calls (swap/drop a plugin, adopt a built-in) need live user confirmation.

## The process

1. **Update.** `vim.pack.update()` downloads updates and opens a confirmation buffer; nothing applies until `:write` (bare `:quit` discards silently, no error). Run:
   ```
   nvim --headless -u init.lua \
     -c "lua vim.pack.update()" \
     -c "lua vim.fn.writefile(vim.api.nvim_buf_get_lines(0,0,-1,false), '/tmp/pack_confirm.txt')" \
     -c "write" \
     -c "qa"
   ```
   `/tmp/pack_confirm.txt` feeds step 3. Verify after with `git diff nvim-pack-lock.json` -- download progress isn't proof it applied. Scope with `vim.pack.update({'name',...})`; add `force = true` only if the user wants to skip review.

2. **See what moved.** `git diff nvim-pack-lock.json`: old → new `rev` per plugin.

3. **See what changed, per plugin.** Clones live under `~/.local/share/nvim/site/pack/core/opt/<name>/`. Sources, in priority order:
   - `/tmp/pack_confirm.txt` (step 1) -- vim.pack's grouped commit list, breaking changes marked `!` (Conventional Commits). Often the only source covering a short audit window; start here.
   - `gh release list -R owner/repo` -- only if a release lands inside the old→new range.
   - `README.md`/`CHANGELOG.md` diff between the two revs -- catches config/setup changes a changelog might miss.
   - `git log --oneline <old>..<new>` as an index to a commit worth reading in full, not something to interpret standalone.
   - Any `!`-marked breaking change: `grep init.lua`/`servers.lua` for the affected option before flagging it -- unset options are non-events.

4. **Re-validate relevance**, not just correctness, for every declared plugin, updated or not. Triage in one batch first:
   ```
   for repo in owner1/plugin1 owner2/plugin2 ...; do
     gh api repos/$repo --jq '.full_name + " | archived=" + (.archived|tostring) + " | pushed_at=" + .pushed_at'
   done
   ```
   `archived=true`, or staleness relative to what the plugin does (a quiet utility plugin for a year is normal), signals escalation. For flagged plugins only, go deeper: `:help news` for a built-in replacement; AGENTS.md's "Researching issues" section for a better-maintained alternative.

   Never silently swap or drop a plugin -- surface findings as decisions for the user.

5. **Test.** Every `init.lua`/`servers.lua` edit: AGENTS.md's "Test every change" workflow (both headless checks exit 0, then exercise the change) before reporting done.

## Cleaning up

Removing a plugin from `vim.pack.add{...}` doesn't delete its clone. Run `vim.pack.del({'plugin-name'})` too, or the stale clone triggers "Repaired corrupted lock data" warnings later.

## Reporting back

Report: plugins moved (rev + one-line summary), plugins re-evaluated and kept, and open questions for the user. After sign-off and testing: check `git status`, ask before committing -- never commit unasked, and don't take credit for auto-checkpoint commits you didn't make.
