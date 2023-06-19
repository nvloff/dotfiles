-- return {
--     -- NOTE: This is where your plugins related to LSP can be installed.
--     --  The configuration is done below. Search for lspconfig to find it below.
--     {
--         -- LSP Configuration & Plugins
--         'neovim/nvim-lspconfig',
--         dependencies = {
--             -- Automatically install LSPs to stdpath for neovim
--             { 'williamboman/mason.nvim', config = true },
--             'williamboman/mason-lspconfig.nvim',
--
--             -- Useful status updates for LSP
--             -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
--             { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },
--
--             -- Additional lua configuration, makes nvim stuff amazing!
--             'folke/neodev.nvim',
--         },
--     },
-- }

local icons = require("personal.icons")
local lsp_utils = require("utils.lsp")

local lsp_tools = {
	-- language servers
	"bash-language-server",
	"dockerfile-language-server",
	"gopls",
	"json-lsp",
	"lua-language-server",
	"marksman",
	"taplo",
	"terraform-ls",
	"yaml-language-server",

	-- linters
	"actionlint",
	"golangci-lint",
	"hadolint",
	"jsonlint",
	"markdownlint",

	-- formatters
	"shfmt",
	"stylua",

	-- code actions
	"gomodifytags",
}

-- Define LSP configuration settings for languages
local servers_config = {
	gopls = function()
		return {
			settings = {
				gopls = {
					buildFlags = { "-tags=all,test_setup" },
					codelenses = {
						tidy = true,
						vendor = true,
						generate = true,
						regenerate_cgo = true,
						upgrade_dependency = true,
						gc_details = true,
						test = true,
						run_vulncheck_exp = true,
					},
					analyses = {
						useany = true,
						nilness = true,
						unusedparams = true,
						unusedvariable = true,
						unusedwrite = true,
						shadow = true,
					},
					semanticTokens = true,
					gofumpt = true,
					staticcheck = true,
					importShortcut = "Both",
					completionDocumentation = true,
					linksInHover = true,
					usePlaceholders = true,
					experimentalPostfixCompletions = true,
					hoverKind = "FullDocumentation",
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
				tags = { skipUnexported = true },
			},
		}
	end,
	lua_ls = function()
		local ok, neodev = pcall(require, "neodev")
		if not ok then
			vim.notify("Cannot import 'neodev'. Using empty config", vim.log.levels.WARN)
			return {}
		end

		neodev.setup({})

		return {
			settings = {
				Lua = {
					workspace = {
						checkThirdParty = false,
					},
					format = { enable = false },
				},
			},
		}
	end,
	yamlls = function()
		return {
			settings = {
				yaml = {
					hover = true,
					completion = true,
					format = { enable = true },
					validate = true,
					schemas = {
						["https://json.schemastore.org/chart.json"] = "/kubernetes/*.y*ml",
						["https://json.schemastore.org/golangci-lint.json"] = "*golangci.y*ml",
						["https://json.schemastore.org/kustomization.json"] = "/*kustomization.y*ml",
						["https://json.schemastore.org/swagger-2.0.json"] = "/*swagger.y*ml",
						["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
						["https://json.schemastore.org/travis.json"] = "/*travis.y*ml",
						["https://json.schemastore.org/yamllint.json"] = "/*yamllint.y*ml",
						["https://json.schemastore.org/markdownlint.json"] = "/*.markdownlint.y*ml",
						["https://raw.githubusercontent.com/GoogleContainerTools/skaffold/master/docs/content/en/schemas/v2beta12.json"] = "/*skaffold.y*ml",
					},
					schemaStore = {
						url = "https://www.schemastore.org/json",
						enable = true,
					},
				},
			},
		}
	end,
	jsonls = function()
		return { settings = { json = { format = { enable = true } } } }
	end,
	tilt_ls = function()
		return {
			filetypes = { "tiltfile", "starlark" },
		}
	end,
	clangd = function()
		return {
			capabilities = {
				offsetEncoding = { "utf-16" },
			},
		}
	end,
}

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		init = function()
			lsp_utils.customise_ui()
			lsp_utils.setup_vim_diagnostics()
		end,
		config = function()
			local nvim_lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")
			for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
				local config = lsp_utils.create_config(servers_config, server)
				nvim_lspconfig[server].setup(config)
			end

			if vim.fn.executable("tilt") then
				local config = lsp_utils.create_config(servers_config, "tilt_ls")
				nvim_lspconfig["tilt_ls"].setup(config)
			end
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = icons.ui.check,
					package_pending = icons.ui.play,
					package_uninstalled = icons.ui.times,
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = lsp_tools,
			auto_update = true,
			run_on_start = true,
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				debug = false,
				diagnostics_format = "#{m}",
				on_attach = lsp_utils.on_attach,
				sources = {
					-- diagnostics
					null_ls.builtins.diagnostics.golangci_lint.with({
						extra_args = { "--config", vim.fn.expand("$HOME/rcfiles/golangci-lint/golangci.yml") },
					}),
					null_ls.builtins.diagnostics.hadolint,
					null_ls.builtins.diagnostics.jsonlint,
					null_ls.builtins.diagnostics.markdownlint.with({
						extra_args = {
							"--config",
							vim.fn.expand("$HOME/rcfiles/markdownlint/markdownlint.yaml"),
						},
					}),
					null_ls.builtins.diagnostics.actionlint,

					-- formatting
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.jq,
					null_ls.builtins.formatting.shfmt,
					null_ls.builtins.formatting.markdownlint.with({
						extra_args = {
							"--config",
							vim.fn.expand("$HOME/rcfiles/markdownlint/markdownlint.yaml"),
						},
					}),

					-- code actions
					null_ls.builtins.code_actions.refactoring,
					null_ls.builtins.code_actions.shellcheck,
					null_ls.builtins.code_actions.gomodifytags,

					-- hover
					null_ls.builtins.hover.dictionary,
				},
			})
		end,
	},
	{
		"kosayoda/nvim-lightbulb",
		init = function()
			vim.fn.sign_define(
				"LightBulbSign",
				{ text = icons.ui.lightbulb, texthl = "Character", linehl = "", numhl = "" }
			)
		end,
		opts = {
			autocmd = {
				enabled = true,
			},
		},
	},
	{ "folke/neodev.nvim" },
}
