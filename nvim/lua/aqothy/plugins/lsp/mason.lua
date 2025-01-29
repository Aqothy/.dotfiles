return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	build = ":MasonUpdate",
	cmd = { "Mason", "MasonInstall", "MasonUninstall" },
	config = function()
		local mason = require("mason")

		local mason_lspconfig = require("mason-lspconfig")

		local mason_registry = require("mason-registry")

		mason.setup()

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				-- "html",
				"cssls",
				"tailwindcss",
				"lua_ls",
				"basedpyright",
				"clangd",
				-- "omnisharp",
				"gopls",
				"eslint",
				-- "jdtls",
				"texlab",
				-- "ts_ls", -- just manually download on mason, dk why its broken
				"vtsls",
				"emmet_language_server",
			},
			icons = {
				package_installed = "",
				package_pending = "",
				package_uninstalled = "",
			},
			log_level = vim.log.levels.INFO,
			max_concurrent_installers = 3,
		})

		local tools = {
			"stylua",
			"prettier",
			"gofumpt",
		}

		-- installing tools without mason tool installer
		for _, tool in ipairs(tools) do
			local ok, package = pcall(mason_registry.get_package, tool)
			if ok and not package:is_installed() then
				package:install()
			elseif not ok then
				vim.notify("Mason: Tool " .. tool .. " not found in the registry.", vim.log.levels.WARN)
			end
		end
	end,
}
