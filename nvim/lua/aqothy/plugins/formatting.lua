return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		-- Set up Conform with your desired formatters
		conform.setup({
			log_level = vim.log.levels.DEBUG,
			notify_on_error = false,
			formatters_by_ft = {
				c = { name = "clangd", lsp_format = "prefer" },
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
				go = { "gofumpt" },
				-- For filetypes without a formatter:
				["_"] = { "trim_whitespace", "trim_newlines" },
			},
			format_on_save = function()
				if not vim.g.autoformat then
					return nil
				end
				return {}
			end,
			default_format_opts = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
		})
	end,
}
