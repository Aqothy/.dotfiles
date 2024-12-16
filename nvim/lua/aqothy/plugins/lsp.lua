return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
	-- event = { "BufReadPre", "BufNewFile" },
	-- cmd = { "LspInstall", "LspUninstall", "LspInfo", "Mason" },
	config = function()
		local lspconfig = require("lspconfig")

		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local builtin = require("telescope.builtin")

		local mason = require("mason")

		local mason_tool_installer = require("mason-tool-installer")

		local mason_lspconfig = require("mason-lspconfig")

		mason.setup()

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"html",
				"cssls",
				"tailwindcss",
				"lua_ls",
				"emmet_ls",
				"pyright",
				"clangd",
				"gopls",
				"jdtls",
				"texlab",
				"eslint",
				"ts_ls", -- just manually download on mason, dk why its broken
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier",
				"stylua", -- lua formatter
				"black", -- python formatter
				--"latexindent",
				-- "clang-format",
				"gofumpt",
				"goimports-reviser",
				"golines",
			},
		})

		-- local format_group = vim.api.nvim_create_augroup("LspAutoformat", { clear = true })
		local user_lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = user_lsp_group,

			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				local client = vim.lsp.get_client_by_id(ev.data.client_id)

				if not client then
					return
				end

				-- if client.supports_method("textDocument/formatting") then
				--     -- Format the current buffer on save
				--     vim.api.nvim_create_autocmd("BufWritePre", {
				--         buffer = ev.buf,
				--         group = format_group,
				--         desc = "LSP format on save",
				--         callback = function()
				--             vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
				--         end,
				--     })
				-- end

				-- Key mappings for LSP functions
				-- vim.keymap.set({ "n", "x" }, "<leader>fm", vim.lsp.buf.format, opts)
				vim.keymap.set("n", "<leader>ld", builtin.lsp_definitions, opts) -- show lsp definitions
				vim.keymap.set("n", "<leader>lt", builtin.lsp_type_definitions, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>fd", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "<leader>lr", builtin.lsp_references, opts)
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.goto_next({ float = false })
				end, opts)
				vim.keymap.set("n", "[d", function()
					vim.diagnostic.goto_prev({ float = false })
				end, opts)
			end,
		})

		-- LSP server setup
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			-- require("blink.cmp").get_lsp_capabilities()
			cmp_nvim_lsp.default_capabilities()
		)

		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["lua_ls"] = function()
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				})
			end,
			["clangd"] = function()
				lspconfig["clangd"].setup({
					capabilities = capabilities,
					cmd = {
						"clangd",
						"--fallback-style=LLVM",
					},
				})
			end,
			["pyright"] = function()
				lspconfig["pyright"].setup({
					capabilities = capabilities,
					settings = {
						python = {
							analysis = {
								-- TODO: It would be nice to understand this better and turn these back on someday.
								reportMissingTypeStubs = false,
								typeCheckingMode = "off",
							},
						},
					},
				})
			end,
			["emmet_ls"] = function()
				-- configure emmet language server
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss" },
				})
			end,
		})

		-- Diagnostics Configuration
		vim.diagnostic.config({
			virtual_text = true,
			underline = true,
			-- update_in_insert = false,
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})
	end,
}
