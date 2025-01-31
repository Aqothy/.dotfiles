return {
	"williamboman/mason.nvim",
	build = ":MasonUpdate",
	-- Don't lazy load this plugin :(
	config = function()
		local mason = require("mason")

		local mason_registry = require("mason-registry")

		mason.setup({
			ui = {
				icons = {
					package_installed = "",
					package_pending = "",
					package_uninstalled = "",
				},
			},
			log_level = vim.log.levels.INFO,
			max_concurrent_installers = 3,
		})

		-- List of all LSP servers & tools to install manually
		-- names are different from lspconfig names
		local packages = {
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

			-- Tools (formatters, linters, etc.)
			"stylua",
			"prettier",
			"gofumpt",
		}

		-- installing tools without mason-lspconfig and tool installer
		for _, package_name in ipairs(packages) do
			local ok, pkg = pcall(mason_registry.get_package, package_name)
			if ok then
				if not pkg:is_installed() then
					vim.notify("Mason: Installing " .. package_name, vim.log.levels.INFO)
					pkg:install()
				end
			else
				vim.notify("Mason: Package " .. package_name .. " not found", vim.log.levels.WARN)
			end
		end
	end,
}
