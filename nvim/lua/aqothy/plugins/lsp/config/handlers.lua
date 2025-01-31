local M = {}

M.capabilities = vim.lsp.protocol.make_client_capabilities()

if pcall(require, "blink.cmp") then
	M.capabilities = require("blink.cmp").get_lsp_capabilities(M.capabilities)
elseif pcall(require, "cmp_nvim_lsp") then
	M.capabilities = require("cmp_nvim_lsp").default_capabilities(M.capabilities)
end

M.capabilities.workspace = {
	fileOperations = {
		didRename = true,
		willRename = true,
	},
}

M.capabilities.textDocument.completion.completionItem.snippetSupport = true

M.capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		"documentation",
		"detail",
		"additionalTextEdits",
	},
}

M.capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	signs = false,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = "if_many",
		header = "",
		prefix = "",
	},
})

local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
	return hover({
		border = "rounded",
		max_height = math.floor(vim.o.lines * 0.5),
		max_width = math.floor(vim.o.columns * 0.4),
	})
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
	return signature_help({
		border = "rounded",
		max_height = math.floor(vim.o.lines * 0.5),
		max_width = math.floor(vim.o.columns * 0.4),
	})
end

M.on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, silent = true }
	local keymap = vim.keymap.set

	-- inlay hints
	if client:supports_method("textDocument/inlayHint") then
		-- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		Snacks.toggle.inlay_hints():map("<leader>ti")
	end

	if client:supports_method("textDocument/signatureHelp") then
		keymap({ "n", "i" }, "<C-s>", function()
			local blink_window = require("blink.cmp.completion.windows.menu")
			local blink = require("blink.cmp")
			if blink_window.win:is_open() then
				blink.hide()
			end
			-- local cmp = require("cmp")
			-- if cmp.core.view:visible() then
			-- 	cmp.close()
			-- end
			vim.lsp.buf.signature_help()
		end, opts)
	end

	-- Key mappings for LSP functions
	keymap("n", "K", vim.lsp.buf.hover, opts)
	keymap({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
	keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
	keymap("n", "gh", vim.diagnostic.open_float, opts)
	keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
	keymap("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, opts)
	keymap("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, opts)
	keymap("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end, opts)
	keymap("n", "gr", function()
		Snacks.picker.lsp_references()
	end, vim.tbl_extend("force", opts, { nowait = true, desc = "References" }))
	keymap("n", "gi", function()
		Snacks.picker.lsp_implementations()
	end, opts)
	keymap("n", "<leader>lt", function()
		Snacks.picker.lsp_type_definitions()
	end, opts)
	keymap("n", "<leader>ls", function()
		Snacks.picker.lsp_symbols()
	end, opts)
	keymap("n", "<leader>lS", function()
		Snacks.picker.lsp_workspace_symbols()
	end, opts)
end

return M
