return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		build = ":MasonUpdate",
		cmd = { "Mason", "MasonInstall", "MasonUninstall" },
		config = function()
			local mason = require("mason")

			local mason_lspconfig = require("mason-lspconfig")

			mason.setup()

			-- TODO: Need to install formatters manually in Mason for new setup
			-- prettier, stylua, gofumpt
			mason_lspconfig.setup({
				-- list of servers for mason to install
				ensure_installed = {
					-- "html",
					"cssls",
					"tailwindcss",
					"lua_ls",
					"basedpyright",
					"clangd",
					"omnisharp",
					"gopls",
					-- "jdtls",
					"texlab",
					-- "ts_ls", -- just manually download on mason, dk why its broken
					"vtsls",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
		},
		event = { "LazyFile" },
		cmd = { "LspInstall", "LspUninstall", "LspInfo" },
		config = function()
			local lspconfig = require("lspconfig")

			local fzf = require("fzf-lua")

			local mason_lspconfig = require("mason-lspconfig")

			-- local format_group = vim.api.nvim_create_augroup("LspAutoformat", { clear = true })
			local user_lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

			-- set quickfix list from diagnostics in a certain buffer, not the whole workspace
			local set_qflist = function(buf_num, severity)
				local diagnostics = nil
				diagnostics = vim.diagnostic.get(buf_num, { severity = severity })

				local qf_items = vim.diagnostic.toqflist(diagnostics)
				vim.fn.setqflist({}, " ", { title = "Buffer Diagnostics", items = qf_items })
				vim.cmd([[copen]])
			end

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

					-- inlay hints
					if client.supports_method("textDocument/inlayHint") then
						-- even thought omnisharp doesnt support inlay hints, it still bugs out for some reason so need this to fix it
						if client.name ~= "omnisharp" then
							vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
							Snacks.toggle.inlay_hints():map("<leader>ti")
						end
					end

					-- Key mappings for LSP functions
					-- vim.keymap.set({ "n", "x" }, "<leader>k", vim.lsp.buf.format, opts)
					vim.keymap.set("n", "<leader>ld", fzf.lsp_definitions, opts) -- show lsp definitions
					vim.keymap.set("n", "<leader>lt", fzf.lsp_typedefs, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", fzf.lsp_code_actions, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>fd", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "<leader>lr", fzf.lsp_references, opts)
					vim.keymap.set("n", "<leader>li", fzf.lsp_implementations, opts)
					-- vim.keymap.set("n", "<leader>ws", fzf.lsp_workspace_symbols, opts)
					vim.keymap.set("n", "<leader>ds", fzf.lsp_document_symbols, opts)
					vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.goto_next()
					end, opts)
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.goto_prev()
					end, opts)

					vim.keymap.set("n", "<leader>tt", function()
						vim.diagnostic.setqflist({ open = true })
					end, { desc = "Send workspace diagnostics to quickfix list" })

					vim.keymap.set("n", "<leader>td", function()
						set_qflist(ev.buf)
					end, { desc = "Send buffer diagnostics to quickfix list" })

					-- vim.api.nvim_create_autocmd("CursorHold", {
					-- 	buffer = ev.buf,
					-- 	callback = function()
					-- 		if not vim.b.diagnostics_pos then
					-- 			vim.b.diagnostics_pos = { nil, nil }
					-- 		end
					--
					-- 		local cursor_pos = vim.api.nvim_win_get_cursor(0)
					-- 		if
					-- 			(cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
					-- 			and #vim.diagnostic.get() > 0
					-- 		then
					-- 			vim.diagnostic.open_float()
					-- 		end
					--
					-- 		vim.b.diagnostics_pos = cursor_pos
					-- 	end,
					-- })
				end,
			})

			-- LSP server setup
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("blink.cmp").get_lsp_capabilities()
			)

			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			mason_lspconfig.setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,
				-- ["ts_ls"] = function()
				--     lspconfig["ts_ls"].setup({
				--         capabilities = capabilities,
				--         settings = {
				--             typescript = {
				--                 inlayHints = {
				--                     includeInlayParameterNameHints = 'literals', -- 'none' | 'literals' | 'all';
				--                     includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				--                     includeInlayFunctionParameterTypeHints = true,
				--                     includeInlayVariableTypeHints = false,
				--                     includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				--                     includeInlayPropertyDeclarationTypeHints = true,
				--                     includeInlayFunctionLikeReturnTypeHints = true,
				--                     includeInlayEnumMemberValueHints = true,
				--                 }
				--             },
				--         }
				--     })
				-- end,
				["tailwindcss"] = function()
					lspconfig["tailwindcss"].setup({
						capabilities = capabilities,
						-- make tailwind lsp only load with projects that have tailwind config
						root_dir = function(fname)
							local root_pattern = lspconfig.util.root_pattern(
								"tailwind.config.js",
								"tailwind.config.cjs",
								"tailwind.config.mjs",
								"tailwind.config.ts",
								"postcss.config.js",
								"postcss.config.cjs",
								"postcss.config.mjs",
								"postcss.config.ts"
							)
							return root_pattern(fname)
						end,
					})
				end,
				["vtsls"] = function()
					lspconfig["vtsls"].setup({
						capabilities = capabilities,
						settings = {
							complete_function_calls = true,
							vtsls = {
								enableMoveToFileCodeAction = true,
								autoUseWorkspaceTsdk = true,
								experimental = {
									maxInlayHintLength = 30,
									completion = {
										enableServerSideFuzzyMatch = true,
									},
								},
							},
							typescript = {
								updateImportsOnFileMove = { enabled = "always" },
								suggest = {
									completeFunctionCalls = true,
								},
								inlayHints = {
									enumMemberValues = { enabled = true },
									functionLikeReturnTypes = { enabled = true },
									parameterNames = { enabled = "literals" },
									parameterTypes = { enabled = true },
									propertyDeclarationTypes = { enabled = true },
									variableTypes = { enabled = false },
								},
							},
						},
					})
				end,
				["lua_ls"] = function()
					lspconfig["lua_ls"].setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim", "Snacks" },
								},
								workspace = {
									checkThirdParty = false,
								},
								doc = {
									privateName = { "^_" },
								},
								hint = {
									enable = true,
									setType = false,
									paramType = true,
									paramName = "Disable",
									semicolon = "Disable",
									arrayIndex = "Disable",
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
							"--background-index",
							"--offset-encoding=utf-16",
							"--clang-tidy",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--fallback-style=LLVM",
						},
						init_options = {
							usePlaceholders = true,
							completeUnimported = true,
							clangdFileStatus = true,
						},
					})
				end,
				["gopls"] = function()
					lspconfig["gopls"].setup({
						settings = {
							gopls = {
								gofumpt = true,
								codelenses = {
									gc_details = false,
									generate = true,
									regenerate_cgo = true,
									run_govulncheck = true,
									test = true,
									tidy = true,
									upgrade_dependency = true,
									vendor = true,
								},
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
								analyses = {
									fieldalignment = true,
									nilness = true,
									unusedparams = true,
									unusedwrite = true,
									useany = true,
								},
								usePlaceholders = true,
								completeUnimported = true,
								staticcheck = true,
								directoryFilters = { "-.git", "-.vscode", "-node_modules" },
							},
						},
					})
				end,
				-- ["pyright"] = function()
				-- 	lspconfig["pyright"].setup({
				-- 		capabilities = capabilities,
				-- 		settings = {
				-- 			python = {
				-- 				analysis = {
				-- 					-- TODO: It would be nice to understand this better and turn these back on someday.
				-- 					reportMissingTypeStubs = false,
				-- 					typeCheckingMode = "off",
				-- 				},
				-- 			},
				-- 		},
				-- 	})
				-- end,
				["basedpyright"] = function()
					lspconfig["basedpyright"].setup({
						capabilities = capabilities,
						settings = {
							basedpyright = {
								analysis = {
									-- TODO: It would be nice to understand this better and turn these back on someday.
									reportMissingTypeStubs = false,
									reportMissingSuperCall = false,
									typeCheckingMode = "off",
								},
							},
						},
					})
				end,
				["emmet_language_server"] = function()
					-- configure emmet language server
					lspconfig["emmet_language_server"].setup({
						capabilities = capabilities,
						filetypes = {
							"astro",
							"css",
							"heex",
							"html",
							"html-eex",
							"javascript",
							"javascriptreact",
							"rust",
							"svelte",
							"typescript",
							"typescriptreact",
							"vue",
						},
					})
				end,
				["omnisharp"] = function()
					lspconfig["omnisharp"].setup({
						capabilities = capabilities,
						settings = {
							FormattingOptions = {
								EnableEditorConfigSupport = true,
								OrganizeImports = true,
							},
							RoslynExtensionsOptions = {
								-- EnableAnalyzersSupport = true,
								EnableImportCompletion = true,
								AnalyzeOpenDocumentsOnly = false,
							},
						},
					})
				end,
			})

			local user = require("aqothy.config.user")

			local s = vim.diagnostic.severity

			local signs = {
				text = {
					[s.ERROR] = user.signs.error,
					[s.WARN] = user.signs.warn,
					[s.HINT] = user.signs.hint,
					[s.INFO] = user.signs.info,
				},
				numhl = {
					[s.ERROR] = "DiagnosticSignError",
					[s.WARN] = "DiagnosticSignWarn",
					[s.HINT] = "DiagnosticSignHint",
					[s.INFO] = "DiagnosticSignInfo",
				},
			}

			-- Diagnostics Configuration
			vim.diagnostic.config({
				virtual_text = true,
				underline = true,
				update_in_insert = false,
				signs = signs,
				severity_sort = true,
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
	},
}
