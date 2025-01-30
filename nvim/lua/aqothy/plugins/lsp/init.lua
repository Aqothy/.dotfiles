local M = {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
	},
	event = { "LazyFile" },
	cmd = { "LspInstall", "LspUninstall", "LspInfo" },
}

M.config = function()
	local lspconfig = require("lspconfig")

	require("aqothy.plugins.lsp.config.handlers").diagnostic_config()

	local params = {
		capabilities = require("aqothy.plugins.lsp.config.handlers").capabilities,
	}

	local settings = require("aqothy.plugins.lsp.config.settings")
	for lsp, opts in pairs(settings) do
		if opts.enabled ~= false then
			lspconfig[lsp].setup(vim.tbl_deep_extend("force", params, opts))
		end
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),

		callback = function(ev)
			local opts = { buffer = ev.buf, silent = true }

			local client = vim.lsp.get_client_by_id(ev.data.client_id)

			if not client then
				return
			end

			-- inlay hints
			if client.supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
				Snacks.toggle.inlay_hints():map("<leader>ti")
			end

			-- Key mappings for LSP functions
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "gh", vim.diagnostic.open_float, opts)
			vim.keymap.set({ "n", "i" }, "<C-s>", function()
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
			vim.keymap.set("n", "]d", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, opts)
			vim.keymap.set("n", "[d", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end, opts)
		end,
	})
end

return M
