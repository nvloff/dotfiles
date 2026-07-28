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
      codelenses = {
        tidy = true,
        vendor = true,
        generate = true,
        regenerate_cgo = true,
        upgrade_dependency = true,
        gc_details = true,
        run_vulncheck_exp = true,
      },
      analyses = {
        useany = true,
        nilness = true,
        unusedparams = true,
        unusedvariable = true,
        unusedwrite = true,
        shadow = false,
        loopclosure = false,
      },
      semanticTokens = true,
      gofumpt = true,
      staticcheck = true,
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
vim.lsp.enable({
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
