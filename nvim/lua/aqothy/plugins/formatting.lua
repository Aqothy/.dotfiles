return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Set up Conform with your desired formatters
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescriptreact = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				lua = { "stylua" },
				python = { "black" },
				--				tex = { "latexindent" },
				--                cpp = { "clang-format" },
				go = { "gofumpt", "golines", "goimports-reviser" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		-- Keybinding for manual formatting
		--	vim.keymap.set("n", "<C-s>", function()
		--		conform.format({
		--			lsp_fallback = true,
		--			async = false,
		--			timeout_ms = 1000,
		--		})
		--	end, { desc = "Format file" })

		local group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

		-- Auto-format on write
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = group,
			callback = function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end,
		})
	end,
}
