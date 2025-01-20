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
				-- even thought omnisharp doesnt support inlay hints, it still bugs out for some reason so need this to fix it
				if client.name ~= "omnisharp" then
					vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					Snacks.toggle.inlay_hints():map("<leader>ti")
				end
			end

			-- Key mappings for LSP functions
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>k", vim.diagnostic.open_float, opts)
			vim.keymap.set({ "n", "i" }, "<C-s>", function()
				local cmp = require("cmp")
				if cmp.core.view:visible() then
					cmp.close()
				end
				vim.lsp.buf.signature_help()
			end, opts)
			vim.keymap.set("n", "]d", function()
				vim.diagnostic.goto_next()
			end, opts)
			vim.keymap.set("n", "[d", function()
				vim.diagnostic.goto_prev()
			end, opts)
		end,
	})
end

return M
