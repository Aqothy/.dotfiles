return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
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
		vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

		-- Set up Conform with your desired formatters
		conform.setup({
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
				return { timeout_ms = 500 }
			end,
			default_format_opts = {
				lsp_format = "fallback",
			},
		})
	end,
}
