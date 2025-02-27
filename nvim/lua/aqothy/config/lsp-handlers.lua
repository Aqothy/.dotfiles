local M = {}

local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local has_blink, blink = pcall(require, "blink.cmp")

M.capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	has_cmp and cmp_nvim_lsp.default_capabilities() or {},
	has_blink and blink.get_lsp_capabilities() or {}
)

M.capabilities.workspace = {
	fileOperations = {
		didRename = true,
		willRename = true,
	},
}

M.capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		"documentation",
		"detail",
		"additionalTextEdits",
	},
}

local s = vim.diagnostic.severity

local signs = {
	text = {
		[s.ERROR] = "",
		[s.WARN] = "",
		[s.HINT] = "",
		[s.INFO] = "",
	},
	numhl = {
		[s.ERROR] = "DiagnosticSignError",
		[s.WARN] = "DiagnosticSignWarn",
		[s.HINT] = "DiagnosticSignHint",
		[s.INFO] = "DiagnosticSignInfo",
	},
}

local config = {
	signs = signs,
	virtual_text = true,
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = "if_many",
		header = "",
		prefix = "",
	},
}

vim.diagnostic.config(config)

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

local diagnostic_goto = function(next, severity)
	severity = severity and vim.diagnostic.severity[severity] or nil

	return function()
		vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
	end
end

M.on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, silent = true }

	-- Custom function to wrap keymap setting
	local function keymap(mode, lhs, rhs, extra_opts)
		vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, extra_opts or {}))
	end

	-- Inlay hints
	if client:supports_method("textDocument/inlayHint") then
		-- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		Snacks.toggle.inlay_hints():map("<leader>ti")
	end

	-- Signature help
	if client:supports_method("textDocument/signatureHelp") then
		local blink_window = require("blink.cmp.completion.windows.menu")
		-- local cmp = require("cmp")

		keymap("i", "<C-b>", function()
			if blink_window.win:is_open() then
				blink.hide()
			end
			-- if cmp.core.view:visible() then
			-- 	cmp.close()
			-- end
			vim.lsp.buf.signature_help()
		end)
	end

	-- Key mappings for LSP functions
	keymap("n", "K", vim.lsp.buf.hover)
	keymap({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action)
	keymap("n", "<leader>rn", vim.lsp.buf.rename)
	keymap("n", "<leader>.", vim.diagnostic.open_float)
	keymap("n", "<leader>li", function()
		Snacks.picker.lsp_config()
	end, { desc = "Lsp Info" })
	keymap("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
	keymap("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
	keymap("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
	keymap("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
	keymap("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
	keymap("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

	-- Snacks picker mappings
	keymap("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end)
	keymap("n", "gr", function()
		Snacks.picker.lsp_references()
	end, { nowait = true, desc = "References" })
	keymap("n", "gi", function()
		Snacks.picker.lsp_implementations()
	end)
	keymap("n", "<leader>lt", function()
		Snacks.picker.lsp_type_definitions()
	end)
	keymap("n", "<leader>ls", function()
		Snacks.picker.lsp_symbols()
	end)
	keymap("n", "<leader>lS", function()
		Snacks.picker.lsp_workspace_symbols()
	end)
end

return M
