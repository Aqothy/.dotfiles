local M = {}

-- use enabled field to disable or enable a lsp

M["tailwindcss"] = {
	root_dir = function(fname)
		local util = require("lspconfig.util")

		-- Look for Tailwind configuration files
		local root_pattern =
			util.root_pattern("tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts")(
				fname
			)

		if root_pattern then
			return root_pattern
		end

		-- Return nil if no Tailwind-specific files or dependencies are found
		return nil
	end,
}

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
}

M["omnisharp"] = {
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
}

M["cssls"] = {}

M["texlab"] = {}

return M
