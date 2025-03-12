local M = {}

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

M["tailwindcss"] = {
	enabled = true,
	filetypes = {
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
}

M["eslint"] = {
	enabled = true,
	settings = {
		-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
		workingDirectories = { mode = "auto" },
		format = false,
	},
}

M["vtsls"] = {
	enabled = true,
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
}

M["lua_ls"] = {
	on_init = function(client)
		local path = client.workspace_folders and client.workspace_folders[1] and client.workspace_folders[1].name
		if not path or not (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							"${3rd}/luv/library",
						},
					},
				},
			})
			client:notify(
				vim.lsp.protocol.Methods.workspace_didChangeConfiguration,
				{ settings = client.config.settings }
			)
		end

		return true
	end,
	settings = {
		Lua = {
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
		telemetry = {
			enable = false,
		},
	},
}

M["clangd"] = {
	capabilities = {
		offsetEncoding = { "utf-16" },
	},
	cmd = {
		"clangd",
		"--background-index",
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
}

M["gopls"] = {
	settings = {
		gopls = {
			gofumpt = true,
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
}

M["basedpyright"] = {
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
			},
		},
	},
}

M["emmet_language_server"] = {
	enabled = true,
	filetypes = {
		"css",
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	init_options = {
		showSuggestionsAsSnippets = true,
	},
}

M["sourcekit"] = {
	filetypes = { "swift", "objc", "objcpp" },
}

M["cssls"] = {}

M["texlab"] = {}

M["ruff"] = {}

return M
