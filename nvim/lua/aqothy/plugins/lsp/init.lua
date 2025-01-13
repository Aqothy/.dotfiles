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

	local fzf = require("fzf-lua")

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

	-- set quickfix list from diagnostics in a certain buffer, not the whole workspace
	local set_qflist = function(buf_num, severity)
		local diagnostics = nil
		diagnostics = vim.diagnostic.get(buf_num, { severity = severity })

		local qf_items = vim.diagnostic.toqflist(diagnostics)
		vim.fn.setqflist({}, " ", { title = "Buffer Diagnostics", items = qf_items })
		vim.cmd([[copen]])
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
			-- vim.keymap.set({ "n", "x" }, "<leader>k", vim.lsp.buf.format, opts)
			vim.keymap.set("n", "<leader>ld", fzf.lsp_definitions, opts) -- show lsp definitions
			vim.keymap.set("n", "<leader>lt", fzf.lsp_typedefs, opts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set({ "n", "v" }, "<leader>ca", fzf.lsp_code_actions, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>fd", vim.diagnostic.open_float, opts)
			vim.keymap.set("n", "<leader>lr", fzf.lsp_references, opts)
			vim.keymap.set("n", "<leader>li", fzf.lsp_implementations, opts)
			vim.keymap.set("n", "<leader>ds", fzf.lsp_document_symbols, opts)
			vim.keymap.set("i", "<C-s>", function()
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

			vim.keymap.set("n", "<leader>tt", function()
				vim.diagnostic.setqflist({ open = true })
			end, { desc = "Send workspace diagnostics to quickfix list" })

			vim.keymap.set("n", "<leader>td", function()
				set_qflist(ev.buf)
			end, { desc = "Send buffer diagnostics to quickfix list" })
		end,
	})
end

return M
