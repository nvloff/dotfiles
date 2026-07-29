# AGENTS.md

Instructions for AI agents working on this Neovim configuration.

Target: **Neovim 0.12+**. 0.12 absorbed a plugin manager, native insert-mode autocompletion, an improved default statusline, undotree, diff, and HTTP into core — rely on those.

## Philosophy

This is a **minimal, single-file Neovim configuration**. Guiding principles:

1. **Prefer built-in features over plugins.** 0.12 ships with a plugin manager (`vim.pack`), native LSP (`vim.lsp.config` / `vim.lsp.enable`), insert-mode autocomplete (`'autocomplete'`), tree-sitter, netrw, `:find`, `:terminal`, `gc` commenting, `:Undotree`, `:Diff`, `vim.net.request`, and a useful default statusline. Use them.
2. **Minimal files.** Plugin declarations, options, keymaps, and autocommands live in `init.lua`. The one sanctioned exception is LSP server configs, which live in `servers.lua` (top-level, loaded via `dofile`). Add a `vim.lsp.config` block there for each server installed via `:Mason`. No `lua/` subdirectories.
3. **`vim.pack` only.** If a plugin is justified, declare it with `vim.pack.add`. Do **not** introduce lazy.nvim, packer, vim-plug, rocks.nvim, or any other manager.
4. **Simplicity over cleverness.** Readable Lua beats abstract helpers. A 150-line config a human can read top-to-bottom beats a 1500-line "framework".

## Researching issues

When diagnosing a plugin behaviour, compatibility question, or unexpected Neovim interaction, go to primary sources before guessing:

1. **Plugin GitHub repo** — check Issues, Discussions, and PRs. Search for the symptom. Maintainer replies and closed issues with "completed" labels are the most reliable signal.
2. **r/neovim** — useful for real-world usage patterns and version-specific gotchas, but **filter to recent posts only** (last 12 months). Older advice often targets pre-0.10 configs with lspconfig/packer/cmp that no longer apply.
3. **Neovim's own repo** — `github.com/neovim/neovim` issues and changelogs for anything touching built-in behaviour (`vim.lsp`, `vim.pack`, `autocomplete`, treesitter, etc.).

Prefer GitHub over generic web results. Cite the issue/PR/post URL in your response so the user can follow up.

## Periodic plugin audit

When asked to update plugins and re-validate the config (a recurring, user-triggered task — never automate or schedule this unattended, several steps below are judgment calls that need the user's sign-off):

1. **Update.** Run `vim.pack.update()` to bump every plugin to its latest commit (rewrites `nvim-pack-lock.json`). Scope to specific plugins with `vim.pack.update({ 'name', ... })` if wanted.
2. **See what moved.** `git diff nvim-pack-lock.json` shows exactly which plugins changed and their old → new `rev`. No need to ask the user what changed.
3. **See what actually changed, per plugin.** Each plugin is a full (non-shallow) git clone under `~/.local/share/nvim/site/pack/core/opt/<plugin>/`. For every plugin whose rev moved, run `git -C <that-dir> log --oneline <old-rev>..<new-rev>` for the exact commit list, and diff `CHANGELOG.md` between the two revs if one exists. This is precise — don't guess or rely on memory of a plugin's history.
4. **Re-validate relevance, not just correctness.** For each plugin in `init.lua` — updated or not — re-run the "Before adding a plugin" questions in reverse: is there now a built-in that covers this (check `:help news` for versions released since it was added)? Has a better-maintained alternative emerged (check via "Researching issues" above)? Is the plugin itself now unmaintained or deprecated? Surface findings as decisions for the user, the same way a new addition would be — don't silently swap or remove anything.
5. **Test.** Every resulting edit to `init.lua` still goes through the full "Test every change" workflow below before being reported done.

## Test every change — non-negotiable

**Never report a change as done without running it.** "It should work" is not acceptable. If the change was not executed, it is not done.

Required workflow for every edit to `init.lua`:

1. Make the edit.
2. Run the headless checks — both must exit 0:
   ```
   nvim -u init.lua --headless "+checkhealth" "+qa"
   nvim -u init.lua --headless "+lua print('ok')" "+qa"
   ```
3. Start Neovim (`nvim`) or `:restart` an existing session and **exercise the specific thing you changed**: trigger the mapping, run the command, open a file that activates the autocmd, attach the LSP, etc.
4. Only after steps 2 and 3 pass, report the change as complete. In the report, state what was run and what was observed (e.g. "ran `:checkhealth`, clean; opened `foo.ts`, LSP attached, `gd` jumps").

If any step fails, fix it or revert. Do not hand back a broken config and ask the user to test.

If a change genuinely cannot be tested in the agent's environment (e.g. no LSP binary installed, no GUI), say so explicitly and list what the user needs to verify manually. Don't silently skip.

## Before adding a plugin

Ask, in order:

1. Is there a built-in for this? Check `:help` first. In 0.12 the answer is "yes" more often than you think.
2. Can existing options/mappings cover it with 3–5 lines of Lua?
3. Only if both fail: add it via `vim.pack.add`, inline in `init.lua`, with a one-line comment explaining why built-ins are insufficient.

## Built-ins to reach for first

- **Plugin management:** `vim.pack.add{ ... }`, `vim.pack.update{}`, `vim.pack.del{ ... }`. Commit `pack-lock.json` to version control.
- **LSP:** `vim.lsp.config('name', { ... })` + `vim.lsp.enable({ 'name', ... })`. `:lsp` to inspect clients. `nvim-lspconfig` is fine to install as a pure data source — it ships `lsp/*.lua` server configs (cmd/filetypes/root_markers) that `vim.lsp.config` auto-discovers and merges from anywhere on `'runtimepath'` (see `:help lsp-config-merge`), no `require('lspconfig')` call needed. Only add your own `vim.lsp.config('name', { ... })` block for settings that differ from its defaults.
- **Completion:** `vim.o.autocomplete = true` plus `vim.lsp.completion.enable(true, client_id, buf, { autotrigger = false })` in an `LspAttach` autocmd. Tune via `'complete'` and `'completeopt'` (e.g. `"menu,menuone,noselect,popup,fuzzy"`). Do not install nvim-cmp, blink.cmp, or similar.
- **File navigation:** `netrw` (`:Explore`, `:Lex`). `:find` with a good `path` and `'wildmenu'`/`'wildmode'`. `:b` with wildmenu for buffers.
- **Fuzzy finding:** `:find **/pattern` usually suffices. Skip telescope/fzf-lua unless there's a concrete, documented need.
- **Grep:** `:grep` / `:vimgrep`, with `grepprg` set to `rg --vimgrep`. Results go to the quickfix list.
- **Diagnostics:** `vim.diagnostic.*`. Don't wrap it.
- **Tree-sitter:** Shipped with Neovim. `vim.treesitter.start()` in a FileType autocmd for supported languages.
- **Commenting:** Built-in `gc` / `gcc`. No Comment.nvim.
- **Undo tree:** `:Undotree` — built-in in 0.12. No mundo/undotree.vim.
- **Diffing:** `:Diff` — built-in in 0.12. No diffview for simple diffs.
- **HTTP:** `vim.net.request()` — no plenary.nvim needed for basic requests.
- **List/fs helpers:** `vim.list.unique`, `vim.list.bisect`, `vim.fs.ext`, `vim.fs.find`, `vim.fs.root`.
- **Statusline / tabline:** The improved 0.12 default statusline already shows diagnostics, LSP progress, and the `◐` busy symbol. Override only if needed, and handwrite it.
- **Formatting:** `gq` with `formatprg`, or `vim.lsp.buf.format()`.
- **Terminal:** `:terminal`.
- **Git:** `:!git …` and the shell.
- **Config iteration:** `:restart` reloads Neovim with the new config without leaving the terminal.

## When a plugin is justified

Declare it directly in `init.lua`:

```lua
vim.pack.add({
  'https://github.com/author/plugin-name',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})
require('plugin-name').setup({ ... })
```

Post-install/update hooks (e.g. `:TSUpdate`) go in a `PackChanged` autocmd, also in `init.lua`.

## `init.lua` ordering

Keep the file top-to-bottom in this order:

1. **Load-order-critical settings** — anything plugins or the editor read at load time. In practice: `vim.g.mapleader`, `vim.g.maplocalleader`, and occasionally `vim.opt.termguicolors`. These must come first.
2. **Options** — regular `vim.opt.*` / `vim.o.*` settings.
3. **Keymaps and autocmds** — `vim.keymap.set`, `vim.api.nvim_create_autocmd`.
4. **Plugin configuration** — `vim.pack.add{ ... }` and any `require('plugin').setup(...)` calls go at the **bottom** of the file.

Reading top-to-bottom should show "what Neovim does on its own" before "what plugins add", so the built-in baseline is obvious without scrolling past plugin noise.

If a specific option genuinely must live next to a plugin for correctness (e.g. a setting the plugin reads during `setup`), keep it with the plugin and add a one-line comment explaining why.

## Style

- `vim.opt` for options, `vim.keymap.set` for mappings, `vim.api.nvim_create_autocmd` for autocommands.
- Group related autocommands under named augroups with `clear = true`.
- Leader is `<Space>`, as set in `init.lua`.
- Prefer `vim.*` APIs over `vim.cmd` string invocations where an equivalent exists.
- Keep comments short; explain *why*, not *what*.

## Don't

- Don't add third-party plugin managers. `vim.pack` is the only manager.
- Don't split `init.lua` into multiple files or modules.
- Don't scatter plugin setup throughout `init.lua`. It goes at the bottom unless order is genuinely required — see "`init.lua` ordering".
- Don't install plugins that thinly wrap built-ins:
  - No nvim-cmp / blink.cmp (use `'autocomplete'` + `vim.lsp.completion`).
  - No `require('lspconfig')` / `.setup{}` calls — that framework is deprecated in favor of `vim.lsp.config` / `vim.lsp.enable`. (Installing `nvim-lspconfig` itself, purely as `lsp/*.lua` config data, is fine — see the LSP built-in entry above.)
  - No Comment.nvim (use `gc`).
  - No mundo / undotree.vim (use `:Undotree`).
  - No lualine / heirline for a basic statusline (the 0.12 default is good).
  - No nvim-tree / neo-tree unless you've genuinely outgrown netrw.
- Don't add abstractions for flexibility that isn't needed now.
- Don't mirror the structure of a popular distro (LazyVim, NvChad, Kickstart, AstroNvim).
- Don't enable `vim._extui` / "ui2" without a reason — it's still experimental.
- **Don't report a change as done without running it.** See "Test every change" above.
