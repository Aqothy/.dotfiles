return {
	"williamboman/mason.nvim",
	build = ":MasonUpdate",
	cmd = "Mason",
	keys = { { "<leader>tm", "<cmd>Mason<cr>", desc = "Mason" } },
	opts_extend = { "ensure_installed" },
	opts = {
		ensure_installed = {
			-- LSP servers
			"css-lsp",
			"tailwindcss-language-server",
			"lua-language-server",
			"basedpyright",
			"clangd",
			"gopls",
			"eslint-lsp",
			"texlab",
			"vtsls",
			"emmet-language-server",
			"ruff",
			"bash-language-server",

			-- Formatters/linters
			"stylua",
			"prettier",
			"gofumpt",
			"goimports",

			-- Dap
			"js-debug-adapter",
			"delve",
			"codelldb",
		},

		ui = {
			border = "rounded",
			icons = {
				package_installed = "",
				package_pending = "",
				package_uninstalled = "",
			},
		},

		log_level = vim.log.levels.OFF,
	},
	config = function(_, opts)
		require("mason").setup(opts)

		local mr = require("mason-registry")
		mr:on("package:install:success", function()
			vim.defer_fn(function()
				-- trigger FileType event to possibly load this newly installed LSP server
				require("lazy.core.handler.event").trigger({
					event = "FileType",
					buf = vim.api.nvim_get_current_buf(),
				})
			end, 100)
		end)

		mr.refresh(function()
			for _, tool in ipairs(opts.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					vim.notify("Installing " .. tool)
					p:install()
				end
			end
		end)
	end,
}
