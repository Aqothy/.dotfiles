return {
	"stevearc/conform.nvim",
	lazy = true,
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>k",
			function()
				require("conform").format({ async = true })
			end,
			mode = { "n", "v" },
			desc = "Format buffer",
		},
	},
	config = function()
		local conform = require("conform")

		-- Set up Conform with your desired formatters
		conform.setup({
			log_level = vim.log.levels.DEBUG,
			notify_on_error = false,
			quiet = true,
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
			default_format_opts = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
		})
	end,
}
