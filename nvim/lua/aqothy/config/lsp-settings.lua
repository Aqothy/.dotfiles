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
				-- completion = {
				-- 	enableServerSideFuzzyMatch = true,
				-- },
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
	enabled = true,
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1] and client.workspace_folders[1].name
			if path and (vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc")) then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
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
		})
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
	enabled = true,
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
		"--fallback-style=none",
	},
	init_options = {
		usePlaceholders = true,
		completeUnimported = true,
		clangdFileStatus = true,
	},
}

M["gopls"] = {
	enabled = true,
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
	enabled = true,
	settings = {
		basedpyright = {
			disableOrganizeImports = true,
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
	enabled = true,
	filetypes = { "swift", "objc", "objcpp" },
}

M["cssls"] = {
	enabled = true,
}

M["texlab"] = {
	enabled = true,
}

M["ruff"] = {
	enabled = true,
}

M["bashls"] = {
	enabled = true,
	filetypes = { "bash", "sh", "zsh" },
}

return M
