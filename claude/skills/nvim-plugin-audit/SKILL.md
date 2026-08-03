---
name: nvim-plugin-audit
description: Update this Neovim config's plugins (vim.pack) and re-validate each one is still the right choice. Use for "update/upgrade my nvim plugins", "audit my nvim config", "are my plugins still maintained/relevant", or "revalidate my neovim setup". Not for one-off init.lua edits unrelated to plugins (keymaps, options) -- those are normal edits per AGENTS.md.
---

# Neovim plugin audit

Config lives at `~/.config/nvim`, a stow symlink to `<repo>/nvim/.config/nvim` -- resolve with `readlink -f ~/.config/nvim` and run every command below from there. Uses `vim.pack` as its only plugin manager.

**Manual, user-triggered only.** Never automate or schedule this -- step 4 produces judgment calls (swap/drop a plugin, adopt a built-in) that need the user to see and confirm them live.

## The process

1. **Update.** `vim.pack.update()` downloads updates and opens a confirmation buffer -- it does **not** apply anything until `:write` (a bare `:quit` silently discards everything, no error). Run:
   ```
   nvim --headless -u init.lua \
     -c "lua vim.pack.update()" \
     -c "lua vim.fn.writefile(vim.api.nvim_buf_get_lines(0,0,-1,false), '/tmp/pack_confirm.txt')" \
     -c "write" \
     -c "qa"
   ```
   `/tmp/pack_confirm.txt` is your step-3 input. Verify with `git diff nvim-pack-lock.json` afterward -- don't trust the download progress alone. Scope to specific plugins with `vim.pack.update({'name',...})`; use `force = true` only if the user says they don't want to review conflicts.

2. **See what moved.** `git diff nvim-pack-lock.json` -- old → new `rev` per plugin, no need to ask the user.

3. **See what changed, per plugin.** Plugins are full git clones under `~/.local/share/nvim/site/pack/core/opt/<name>/`. In priority order:
   - `/tmp/pack_confirm.txt` from step 1 -- vim.pack's own grouped commit list, breaking changes marked `!` (Conventional Commits). Usually the only source that actually covers a short audit window; start here.
   - `gh release list -R owner/repo` / `gh api repos/owner/repo/releases` -- only useful if a release actually lands inside the old→new range.
   - `README.md`/`CHANGELOG.md` diff between the two revs -- catches config/setup changes a changelog might miss.
   - `git log --oneline <old>..<new>` as an index to find a specific commit worth reading in full, not something to interpret standalone.
   - For anything marked breaking: `grep` `init.lua`/`servers.lua` for the affected option before treating it as actionable -- a breaking change to something you don't set is a non-event.

4. **Re-validate relevance**, not just correctness, for every declared plugin (updated or not). Triage cheaply first, one batch:
   ```
   for repo in owner1/plugin1 owner2/plugin2 ...; do
     gh api repos/$repo --jq '.full_name + " | archived=" + (.archived|tostring) + " | pushed_at=" + .pushed_at'
   done
   ```
   `archived=true`, or staleness relative to what the plugin actually does (a tiny utility going quiet for a year is normal), is the signal to escalate. Only for flagged plugins, go deeper: check `:help news` for a built-in replacement, research per AGENTS.md's "Researching issues" section for a better-maintained alternative.

   Never silently swap or drop a plugin -- surface every finding as a decision for the user.

5. **Test.** Every `init.lua`/`servers.lua` edit goes through AGENTS.md's "Test every change" workflow (both headless checks exit 0, then exercise the change) before reporting done.

## Cleaning up

Dropping a plugin from `vim.pack.add{...}` doesn't remove it from disk. Run `vim.pack.del({'plugin-name'})` too, or the stale clone triggers "Repaired corrupted lock data" warnings later.

## Reporting back

Report which plugins moved (rev + one-line summary of what changed), which you re-evaluated and kept, and which raised a question for the user. Once the user signs off and edits are tested, check `git status` and ask before committing -- never commit unasked, and don't take credit for auto-checkpoint commits you didn't make.
