local M = {}

local feat = require("utils.feat")
local icons = require("personal.icons").lspconfig

local function configure_keymaps(bufnr)
	-- Mark features as enabled by default
	feat.Diagnostics:set(bufnr, true)
	feat.Formatting:set(bufnr, true)

	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	local diagnostic_float_opts = {
		focusable = false,
		close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
		border = "rounded",
		source = "always",
		prefix = function(_, i, total)
			if total > 1 then
				return tostring(i) .. ". "
			end

			return ""
		end,
		format = function(diagnostic)
			if diagnostic.code then
				return string.format("%s [%s]", diagnostic.message, diagnostic.code)
			end

			return diagnostic.message
		end,
		scope = "cursor",
		header = { "Diagnostics", "Title" },
	}

	local keymap = require("utils.keymap")
	-- LSP Code actions
	keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition", buffer = bufnr })
	keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration", buffer = bufnr })
	keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", buffer = bufnr })
	keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Implementation", buffer = bufnr })
	keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Type definition", buffer = bufnr })

	keymap.set("n", "<leader>gs", vim.lsp.buf.document_symbol, { desc = "Document symbols", buffer = bufnr })
	keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols", buffer = bufnr })

	-- keymap.set("n", "<leader>gi", vim.lsp.buf.incoming_calls, { desc = "Incoming calls", buffer = bufnr })
	-- keymap.set("n", "<leader>go", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls", buffer = bufnr })
	--
	keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Documentation", buffer = bufnr })

	keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help", buffer = bufnr })

	keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename", buffer = bufnr })
	keymap.set({ "v", "n" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = bufnr })

	keymap.set("n", "<C-l>", vim.lsp.buf.format, { desc = "Format", buffer = bufnr })

	keymap.set("n", "<leader>cl", vim.lsp.codelens.refresh, { desc = "Refresh codelens", buffer = bufnr })
	keymap.set("n", "<leader>rl", vim.lsp.codelens.run, { desc = "Run codelens", buffer = bufnr })

	-- Diagnostics
	keymap.set("n", "[d", function()
		if feat.Diagnostics:is_disabled(bufnr) then
			return
		end
		vim.diagnostic.goto_prev({ float = diagnostic_float_opts })
	end, { desc = "Go to previous diagnostic", buffer = bufnr })
	keymap.set("n", "]d", function()
		if feat.Diagnostics:is_disabled(bufnr) then
			return
		end
		vim.diagnostic.goto_next({ float = diagnostic_float_opts })
	end, { desc = "Go to next diagnostic", buffer = bufnr })
	keymap.set("n", "<leader>cs", function()
		if feat.Diagnostics:is_disabled(bufnr) then
			return
		end
		vim.diagnostic.open_float(nil, vim.tbl_extend("force", diagnostic_float_opts, { scope = "line" }))
	end, { desc = "Show diagnostics", buffer = bufnr })

	-- Toggle Features
	keymap.set("n", "<leader>cef", function()
		feat.Formatting:set(bufnr, true)
	end, { desc = "Enable formatting", buffer = bufnr })
	keymap.set("n", "<leader>cdf", function()
		feat.Formatting:set(bufnr, false)
	end, { desc = "Disable formatting", buffer = bufnr })
	keymap.set("n", "<leader>ced", function()
		feat.Diagnostics:set(bufnr, true)
		vim.diagnostic.enable(bufnr)
	end, { desc = "Enable diagnostics", buffer = bufnr })
	keymap.set("n", "<leader>cdd", function()
		feat.Diagnostics:set(bufnr, false)
		vim.diagnostic.disable(bufnr)
	end, { desc = "Disable diagnostics", buffer = bufnr })

	keymap.register_group("<leader>g", "Goto", { buffer = bufnr })
	keymap.register_group("<leader>c", "LSP", { buffer = bufnr })
	keymap.register_group("<leader>ce", "Enable features", { buffer = bufnr })
	keymap.register_group("<leader>cd", "Disable features", { buffer = bufnr })
	keymap.register_group("<leader>c", "LSP", { buffer = bufnr, mode = "v" })
end

local function configure_autocmds(client, bufnr)
	-- Set autocommands conditional on server_capabilities
	if client.server_capabilities.documentHighlightProvider then
		vim.api.nvim_create_augroup("user_lsp_document_highlight", { clear = false })
		vim.api.nvim_clear_autocmds({
			group = "user_lsp_document_highlight",
			buffer = bufnr,
		})
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = "user_lsp_document_highlight",
			buffer = bufnr,
			desc = "highlight current symbol on hover",
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = "user_lsp_document_highlight",
			buffer = bufnr,
			desc = "clear current symbol highlight",
			callback = vim.lsp.buf.clear_references,
		})
	end

	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_create_augroup("user_lsp_document_format", { clear = false })
		vim.api.nvim_clear_autocmds({
			group = "user_lsp_document_format",
			buffer = bufnr,
		})
		-- local null_ls_command_prefix = "NULL_LS"
		-- vim.api.nvim_create_autocmd('BufWritePre', {
		--   group = 'user_lsp_document_format',
		--   buffer = bufnr,
		--   desc = 'format on save',
		--   callback = function(_)
		--     if feat.Formatting:is_disabled(bufnr) then
		--       return
		--     end
		--     vim.lsp.buf.format({ bufnr = bufnr })

		--     -- Workaround for gopls not organizing imports on vim.lsp.buf.format
		--     -- Call the organizeImports codeActions for *.go files
		--     if vim.bo.filetype == 'go' then
		--       local params = vim.lsp.util.make_range_params()
		--       params.context = { only = { 'source.organizeImports' } }
		--       ---@diagnostic disable-next-line: param-type-mismatch
		--       local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 5000)
		--       for _, res in pairs(result or {}) do
		--         for _, r in pairs(res.result or {}) do
		--           if r.edit then
		--             vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
		--           elseif r.command:sub(1, #null_ls_command_prefix) ~= null_ls_command_prefix then
		--             vim.lsp.buf.execute_command(r.command)
		--           end
		--         end
		--       end
		--     end
		--   end,
		-- })
	end
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function on_attach(client, bufnr)
	configure_keymaps(bufnr)
	configure_autocmds(client, bufnr)

	-- As of v0.11.0, gopls does not send a Semantic Token legend (in a
	-- client/registerCapability message) unless the client supports dynamic
	-- registration. Neovim's LSP client does not support dynamic registration
	-- for semantic tokens, so we need to declare those server_capabilities
	-- ourselves for the time being.
	-- Ref. https://github.com/golang/go/issues/54531
	if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
		local semantic = client.config.capabilities.textDocument.semanticTokens
		client.server_capabilities.semanticTokensProvider = {
			full = true,
			legend = {
				tokenModifiers = semantic.tokenModifiers,
				tokenTypes = semantic.tokenTypes,
			},
			range = true,
		}
	end
end

-- Create config that activates keymaps and enables snippet support
local function create_config(servers, server)
	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	local opts = {
		capabilities = capabilities,
		on_attach = on_attach,
	}

	if servers[server] then
		opts = vim.tbl_deep_extend("force", opts, servers[server]())
	end

	return opts
end

local function customise_ui()
	-- Update the sign icons
	for type, icon in pairs(icons) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end

	-- Update LspInfo window border
	require("lspconfig.ui.windows").default_options.border = "rounded"
end

local function setup_vim_diagnostics()
	vim.diagnostic.config({
		underline = true,
		virtual_text = false,
		signs = true,
		float = {
			border = "rounded",
		},
		update_in_insert = true,
		severity_sort = true,
	})
end

M.on_attach = on_attach
M.create_config = create_config
M.customise_ui = customise_ui
M.setup_vim_diagnostics = setup_vim_diagnostics

return M
