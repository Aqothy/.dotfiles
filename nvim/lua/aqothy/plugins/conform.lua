return {
	"stevearc/conform.nvim",
	dependencies = {
		"mason-org/mason.nvim",
	},
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>F",
			function()
				require("conform").format({ async = true })
			end,
			mode = { "n", "v" },
			desc = "Format Buffer or Selection",
		},
	},
	opts = {
		log_level = vim.log.levels.OFF,
		notify_on_error = false,
		quiet = true,
		formatters_by_ft = {
			c = { name = "clangd", lsp_format = "prefer" },
			cpp = { name = "clangd", lsp_format = "prefer" },
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
			go = { "goimports", "gofumpt" },
			python = { "ruff_format" },
			swift = { name = "sourcekit", lsp_format = "prefer" },
			-- For filetypes without a formatter:
			["_"] = { "trim_whitespace", "trim_newlines" },
		},
		default_format_opts = {
			lsp_format = "fallback",
			timeout_ms = 500,
		},
	},
}
