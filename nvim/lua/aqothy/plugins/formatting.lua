return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Set up Conform with your desired formatters
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "black" },
				-- tex = { "latexindent" },
				--                cpp = { "clang-format" },
				go = { "gofumpt", "golines", "goimports-reviser" },
			},
			format_on_save = {
				lsp_format = "fallback",
				async = false,
				timeout_ms = 3000,
			},
		})

		-- Keybinding for manual formatting
		--	vim.keymap.set("n", "<C-k>", function()
		--		conform.format({
		--			lsp_fallback = true,
		--			async = false,
		--			timeout_ms = 3000,
		--		})
		--	end, { desc = "Format file" })

		-- local group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

		-- Auto-format on write, already done by conform itself
		-- vim.api.nvim_create_autocmd("BufWritePre", {
		--     group = group,
		--     callback = function()
		--         conform.format({
		--             lsp_fallback = true,
		--             async = false,
		--             timeout_ms = 3000,
		--         })
		--     end,
		-- })
	end,
}
