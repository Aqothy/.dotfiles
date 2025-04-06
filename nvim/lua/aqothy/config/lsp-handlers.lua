local M = {}

local has_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local has_blink, blink = pcall(require, "blink.cmp")

M.capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	has_cmp_lsp and cmp_nvim_lsp.default_capabilities() or {},
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

-- M.capabilities.textDocument.foldingRange = {
-- 	dynamicRegistration = false,
-- 	lineFoldingOnly = true,
-- }

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
		source = "if_many",
		header = "",
		prefix = "",
	},
}

vim.diagnostic.config(config)

local float_config = {
	max_height = math.floor(vim.o.lines * 0.5),
	max_width = math.floor(vim.o.columns * 0.4),
}

local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
	return hover(float_config)
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
	return signature_help(float_config)
end

--- HACK: Override `vim.lsp.util.stylize_markdown` to use Treesitter.
---@param bufnr integer
---@param contents string[]
---@param opts table
---@return string[]
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.stylize_markdown = function(bufnr, contents, opts)
	contents = vim.lsp.util._normalize_markdown(contents, {
		width = vim.lsp.util._make_floating_popup_size(contents, opts),
	})
	vim.bo[bufnr].filetype = "markdown"
	vim.treesitter.start(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

	return contents
end

local diagnostic_goto = function(next, severity)
	severity = severity and vim.diagnostic.severity[severity] or nil

	return function()
		vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
	end
end

function M.has(method, client)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if M.has(m, client) then
				return true
			end
		end
		return false
	end
	method = method:find("/") and method or "textDocument/" .. method
	if client.supports_method(method) then
		return true
	end
	return false
end

M.on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, silent = true }

	-- Custom function to wrap keymap setting
	local function keymap(mode, lhs, rhs, extra_opts)
		local has = not extra_opts.has or M.has(extra_opts.has, client)
		local cond = not (extra_opts.cond == false or ((type(extra_opts.cond) == "function") and not extra_opts.cond()))
		extra_opts.cond = nil
		extra_opts.has = nil

		if has and cond then
			vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, extra_opts or {}))
		end
	end

	-- local kinds = require("aqothy.config.user").kinds
	-- local utils = require("aqothy.config.utils")
	-- if client:supports_method("textDocument/completion") then
	-- 	client.server_capabilities.completionProvider.triggerCharacters = vim.split("qwertyuiopasdfghjklzxcvbnm. ", "")
	--
	-- 	vim.lsp.completion.enable(true, client.id, bufnr, {
	-- 		autotrigger = true,
	-- 		convert = function(item)
	-- 			local label_details = item.labelDetails
	-- 			local menu =
	-- 				utils.truncateString((label_details and label_details.description) or item.detail or "", 15)
	--
	-- 			local kind = kinds[vim.lsp.protocol.CompletionItemKind[item.kind]] or "u"
	-- 			return {
	-- 				abbr = item.label:gsub("%b()", ""),
	-- 				kind = kind,
	-- 				menu = menu,
	-- 			}
	-- 		end,
	-- 	})
	--
	-- 	vim.keymap.set("i", "<c-space>", function()
	-- 		vim.lsp.completion.get()
	-- 	end)
	-- end

	-- Inlay hints
	if client:supports_method("textDocument/inlayHint") then
		-- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		Snacks.toggle.inlay_hints():map("<leader>ti")
	end

	-- if client:supports_method("textDocument/foldingRange") then
	-- 	local win = vim.api.nvim_get_current_win()
	-- 	vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
	-- end

	keymap("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
	keymap("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
	keymap("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
	keymap("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
	keymap("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
	keymap("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

    -- stylua: ignore start
    keymap("i", "<c-s>", function()
        local has_cmp, cmp = pcall(require, "cmp")

        if has_blink and blink.is_menu_visible() then
            blink.cancel()
        end
        if has_cmp and cmp.visible() then
            cmp.close()
        end
        return vim.lsp.buf.signature_help()
    end, { desc = "Signature Help", has = "signatureHelp" })

    keymap("n", "K", function() return vim.lsp.buf.hover() end, { desc = "Hover", has = "hover" })
    keymap({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action", has = "codeAction" })
    keymap("n", "<leader>fr", function() Snacks.rename.rename_file() end, { desc = "Rename File", has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } })
    keymap("n", "grn", vim.lsp.buf.rename, { desc = "Rename", has = "rename" })
    keymap("n", "<leader>k", vim.diagnostic.open_float, { desc = "Float Diagnostics" })
    keymap("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition", has = "definition" })
    keymap("n", "grr", function() Snacks.picker.lsp_references() end, { desc = "References", has = "references" })
    keymap("n", "gri", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation", has = "implementation" })
    keymap("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition", has = "typeDefinition" })
    keymap("n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols", has = "documentSymbol" })
    keymap("n", "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols", has = "workspace/symbols" })
    keymap("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Lsp Declaration", has = "declaration" })
    keymap("n", "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Reference", has = "documentHighlight", cond = function() return Snacks.words.is_enabled() end })
    keymap("n", "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Reference", has = "documentHighlight", cond = function() return Snacks.words.is_enabled() end })
    keymap("n", "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Document Diagnostics" })
    keymap("n", "<leader>fD", function() Snacks.picker.diagnostics() end, { desc = "Workspace Diagnostics" })
	-- stylua: ignore end
end

return M
