local M = {}

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

M["tailwindcss"] = {}

M["eslint"] = {
	settings = {
		-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
		workingDirectories = { mode = "auto" },
		format = false,
	},
}

M["vtsls"] = {
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
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.fn.expand("$VIMRUNTIME/lua"),
					vim.fn.expand("${3rd}/luv/library"),
					vim.fn.stdpath("data") .. "/lazy/snacks.nvim/lua",
					-- vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua",
				},
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
}

M["clangd"] = {
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
}

M["basedpyright"] = {
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
}

M["emmet_language_server"] = {
	filetypes = {
		"astro",
		"css",
		"heex",
		"html",
		"html-eex",
		"javascript",
		"javascriptreact",
		"svelte",
		"typescript",
		"typescriptreact",
		"vue",
	},
	init_options = {
		showSuggestionsAsSnippets = true,
	},
}

-- M["omnisharp"] = {
-- 	enable_roslyn_analyzers = true,
-- 	organize_imports_on_format = true,
-- 	enable_import_completion = true,
-- }

M["cssls"] = {}

M["texlab"] = {}

return M
