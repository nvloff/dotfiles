---
name: nvim-plugin-audit
description: Update this Neovim config's plugins (vim.pack) and re-validate that each one is still the right choice. Use whenever the user asks to update/upgrade/bump their Neovim plugins, wants a periodic check-up or "audit" of their nvim config, asks "are my nvim plugins still good/relevant/maintained", wants to know if a newer built-in now covers something a plugin does, or says anything like "let's do the nvim plugin maintenance" or "revalidate my neovim setup". Do not use this for one-off edits to init.lua unrelated to updating or reassessing plugins (e.g. adding a keymap, changing an option) -- those are just normal edits per this repo's AGENTS.md.
---

# Neovim plugin audit

This config (`~/.config/nvim`, a stow symlink to `<repo>/nvim/.config/nvim` on this machine — `pwd -P` or `readlink -f` if unsure where you actually are) uses `vim.pack` as its only plugin manager. This skill is the process for periodically updating every plugin and re-checking that each one still deserves to be there — not just "does it still work" but "is it still the right choice."

This is a **manual, user-triggered process**. Never schedule or automate it to run unattended: step 4 below produces judgment calls (swap a plugin, drop a plugin, adopt a new built-in instead) that need the user to actually see and confirm them, the same way you'd confirm before adding a brand new plugin in the first place. Running this skill means running it *now*, interactively, with the user able to weigh in — not queuing a background job.

This skill file lives with the rest of the user's Claude Code skills (e.g. under `~/.claude/skills/`), not inside the Neovim config it operates on — the two are unrelated locations. Every command below (`nvim`, `git diff`/`git status` on `nvim-pack-lock.json`/`init.lua`, etc.) must be run with the working directory resolved to the real Neovim config directory, not wherever this file happens to be. Resolve it first — `readlink -f ~/.config/nvim` — and `cd` there (or use `git -C`/`nvim -u` with that resolved path) before running anything in "The process" below.

## The process

1. **Update.** Run `vim.pack.update()` to bump every plugin to its latest commit (rewrites `nvim-pack-lock.json`, which lives at the config root next to `init.lua`, tracked in git). Scope to specific plugins with `vim.pack.update({ 'name', ... })` if the user only wants some of them touched.

   **`vim.pack.update()` without `force` does *not* apply anything by itself.** It downloads, then opens a confirmation buffer in a new tabpage — the update is only applied on `:write` (a bare `:quit`/quitting the session discards it *silently*, no error, no warning). A naive headless call like `-c "lua vim.pack.update()" -c "qa"` looks like it worked (you'll see the download progress) but actually threw every update away. Don't do that.

   Instead, run one headless invocation that captures the confirmation buffer for your own review *and* confirms it, in a single pass:
   ```
   nvim --headless -u init.lua \
     -c "lua vim.pack.update()" \
     -c "lua vim.fn.writefile(vim.api.nvim_buf_get_lines(0,0,-1,false), '/tmp/pack_confirm.txt')" \
     -c "write" \
     -c "qa"
   ```
   The `writefile` line dumps the confirmation buffer's contents to a plain file *before* confirming (bypassing its `bufwritecmd`, so it's a pure read) — read that file, it's your step-3 input, see below. The subsequent bare `write` then triggers the real confirm-and-apply. Only pass `vim.pack.update(nil, { force = true })` (skipping the confirmation buffer entirely) if the user has said they don't care about reviewing individual conflicts first.

   After it returns, verify `git diff nvim-pack-lock.json` actually shows the revs you expect moved — don't just trust the download-progress output.

2. **See what moved.** `git diff nvim-pack-lock.json` shows exactly which plugins changed and their old → new `rev`, in one place. No need to ask the user what changed — you can see it directly.

3. **See what actually changed, per plugin.** Each plugin is a full (non-shallow) git clone under `~/.local/share/nvim/site/pack/core/opt/<plugin-name>/` (confirm with `git rev-parse --is-shallow-repository` if ever in doubt). For every plugin whose rev moved, work from human-written summaries first, not raw code:
   - **The confirmation buffer dump from step 1 (`/tmp/pack_confirm.txt`), first.** `vim.pack` already grouped the pending commits per plugin and marks breaking ones with `!` in the subject line (Conventional Commits style, e.g. `fix!: remove default_integrations`) — this costs nothing extra and, for short update windows (days, not a full release cycle), is often the *only* source that actually covers the range. Start here before reaching for anything below; only chase the other sources if this list doesn't make a change's relevance clear.
   - **Release notes**, if the plugin uses GitHub Releases/tags for the range — `gh release list`/`gh api repos/<owner>/<repo>/releases` (or the repo's Releases page) covering the old→new range. High-signal *when a release actually lands inside the range* — for short/frequent audit windows it often doesn't (the range sits entirely between two releases), so don't spend time hunting if `gh release list` shows nothing landing between old and new rev; fall back to the confirmation-buffer commit list instead.
   - **`README.md` diff** between the two revs (`git -C <that-dir> diff <old-rev> <new-rev> -- README.md`) — catches new setup/config requirements, deprecation notices, or renamed options that a changelog might not mention.
   - **`CHANGELOG.md` diff** between the two revs, if the plugin keeps one.
   - **`git log --oneline <old-rev>..<new-rev>`** — treat this as an index to start from (spot a commit that looks relevant, then go read *its* message/PR/issue in full) rather than something to interpret alone. Don't read raw code diffs of implementation files to infer what changed; that's slow and easy to misjudge — if the confirmation-buffer list/release notes/README/changelog/commit messages don't make a change's relevance clear, that's a sign it probably doesn't affect this config, not a cue to go dig through the diff yourself.
   - For anything marked breaking (`!` in the confirmation buffer, or called out in release notes), check whether this config actually uses the affected option/feature (`grep` `init.lua`/`servers.lua`) before treating it as actionable — a breaking change to an option you never set is a non-event.

4. **Re-validate relevance, not just correctness.** For every plugin declared in `init.lua` — updated or not — ask the same questions you'd ask before adding it fresh, in reverse.

   **Triage all of them cheaply first**, one batched loop, before doing deep research on any single one:
   ```
   for repo in owner1/plugin1 owner2/plugin2 ...; do
     gh api repos/$repo --jq '.full_name + " | archived=" + (.archived|tostring) + " | pushed_at=" + .pushed_at + " | stars=" + (.stargazers_count|tostring)'
   done
   ```
   `archived=true` or a `pushed_at` that's stale relative to this audit's cadence is your signal to escalate — deep research is for the plugins this flags, not for all of them by default. A tiny, feature-complete utility plugin (e.g. an alignment or indent-detection plugin) going quiet for a year is normal and not itself a red flag; judge staleness relative to what the plugin does, not a fixed threshold.

   For anything the triage flags (or that the user asks about specifically), go deeper:
   - Is there now a built-in that covers this? Check `:help news` for Neovim versions released since the plugin was added.
   - Has a better-maintained alternative emerged? Research the way this config's `AGENTS.md` describes under "Researching issues" (plugin GitHub repo issues/discussions first, r/neovim filtered to the last 12 months, neovim/neovim's own changelogs for built-in behavior).
   - Is the plugin itself now unmaintained, archived, or deprecated in favor of something else?

   Surface every finding as a decision for the user to make, the same way a new addition would be presented — never silently swap or remove a plugin.

5. **Test.** Every resulting edit to `init.lua`/`servers.lua` goes through this config's standard "Test every change" workflow from `AGENTS.md` (both headless checks must exit 0, then actually exercise whatever changed) before being reported done.

## Cleaning up

If step 4 concludes a plugin should be dropped, removing it from `vim.pack.add{...}` in `init.lua` does *not* remove it from disk — it just stops loading it. Clean up the stale clone with `vim.pack.del({'plugin-name'})` so `nvim-pack-lock.json` and the actual `pack/core/opt/` directory stay in sync. A stale orphaned entry there has caused real confusion before: `vim.pack` prints "Repaired corrupted lock data" warnings for plugins it finds on disk but no longer sees declared anywhere.

## Reporting back

When you finish, tell the user which plugins moved (old rev → new rev, and a one-line summary of what actually changed per plugin, from the release notes/README/changelog/commits you read in step 3), which ones you re-evaluated and kept as-is, and which ones raised a question for them to decide. Silence about what happened during an update defeats the point of this process.

Once the user has signed off on every judgment call and every edit is tested, check `git status` and ask whether to commit — never commit without being asked. Something in this environment may auto-checkpoint commits outside your control (this has happened before); don't rely on that, and don't take credit for a commit you didn't make yourself when reporting what happened.
