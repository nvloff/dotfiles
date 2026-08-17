-- LSP server configs. nvim-lspconfig is installed purely as a data source: its
-- lsp/*.lua files are auto-discovered and merged by vim.lsp.config via
-- 'runtimepath' (see :help lsp-config-merge). We only override settings here;
-- cmd/filetypes/root_markers come from nvim-lspconfig unless noted otherwise.
-- Never call require('lspconfig') or .setup{} -- that framework is deprecated.

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config('gopls', {
  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  settings = {
    gopls = {
      buildFlags = { '-tags=all,integration' },
      -- generate/regenerate_cgo/run_govulncheck/tidy/upgrade_dependency/vendor
      -- are gopls' own defaults as of v0.23 -- nothing to override here.
      -- gc_details is no longer a codelens; it's the gopls.gc_details
      -- command, wired up as :GcDetails in the LspAttach autocmd below.
      analyses = {
        -- Nearly every native analyzer defaults to true as of gopls v0.23
        -- (useany/nilness/unusedparams/unusedvariable/unusedwrite among
        -- them -- useany was also renamed to "any" since). These are the
        -- only deviations from that.
        shadow = false, -- noisy on code that intentionally reuses names
        loopclosure = false, -- mostly moot post-Go 1.22 per-iteration vars
        appendclipped = true, -- suggest slices.Concat over append chains
        slicesdelete = true, -- suggest slices.Delete over append-based deletion
        -- fieldalignment was removed in gopls v0.17 -- hover a struct field
        -- for size/offset info instead (https://go.dev/issue/67762).
      },
      semanticTokens = true,
      gofumpt = true,
      staticcheck = true, -- enable *all* staticcheck.io analyzers, not just gopls' curated subset
      importShortcut = 'Both',
      completionDocumentation = true,
      linksInHover = true,
      usePlaceholders = false,
      experimentalPostfixCompletions = true,
      hoverKind = 'FullDocumentation',
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        ignoredError = true, -- flag silently discarded errors, e.g. f.Close()
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

vim.lsp.config('yamlls', {
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = { format = { enable = true } },
  },
})

-- bashls, dockerls, marksman, jsonls, terraformls, helm_ls, tilt_ls need no
-- overrides -- nvim-lspconfig's defaults are used as-is.
local servers = {
  'lua_ls',
  'gopls',
  'bashls',
  'dockerls',
  'marksman',
  'jsonls',
  'terraformls',
  'yamlls',
  'helm_ls',
  'tilt_ls',
}
vim.lsp.enable(servers)

-- Install every server above through Mason on startup, so a fresh machine
-- doesn't need a manual `:MasonInstall` pass. Mason package names
-- occasionally differ from the lspconfig server name above; gopls and
-- marksman happen to match.
require('mason-tool-installer').setup({
  ensure_installed = {
    'lua-language-server',
    'gopls',
    'bash-language-server',
    'dockerfile-language-server',
    'marksman',
    'json-lsp',
    'terraform-ls',
    'yaml-language-server',
    'helm-ls',
    'tilt',
  },
})

-- Plain "helm" filetype is a Helm template (not a values file): helm_ls covers
-- it fully, and yamlls' YAML-schema validation just produces noise there.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('HelmDetachYamlls', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'yamlls' and vim.bo[args.buf].filetype == 'helm' then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, client.id)
      end)
    end
  end,
})
