local M = {}

local utils = require("aqothy.config.utils")

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

M["tailwindcss"] = {
    enabled = false,
}

M["eslint"] = {
    enabled = true,
    settings = {
        -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
        workingDirectories = { mode = "auto" },
        format = false,
    },
    keys = {
        {
            "<leader>fa",
            "<cmd>LspEslintFixAll<cr>",
            {
                desc = "Fix all",
            },
        },
    },
}

local jsts_config = {
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
}

M["vtsls"] = {
    enabled = true,
    settings = {
        vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
                maxInlayHintLength = 30,
                completion = {
                    enableServerSideFuzzyMatch = true,
                    entriesLimit = 200,
                },
            },
        },
        typescript = jsts_config,
        javascript = jsts_config,
    },
    keys = {
        {
            "<leader>oi",
            function()
                utils.action("source.addMissingImports.ts")
                vim.defer_fn(function()
                    utils.action("source.organizeImports")
                end, 100)
            end,
            {
                desc = "Organize Imports",
            },
        },
        {
            "<leader>rm",
            function()
                utils.action("source.removeUnused.ts")
            end,
            {
                desc = "Remove Unused",
            },
        },
    },
}

M["lua_ls"] = {
    enabled = true,
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
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=Google",
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
    keys = {
        { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "Switch Source/Header (C/C++)" } },
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
        },
    },
    keys = {
        {
            "<leader>fi",
            function()
                utils.action("refactor.rewrite.fillStruct")
            end,
            {
                desc = "Fill Struct",
            },
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
    enabled = false,
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
    keys = {
        { "<localleader>ll", "<cmd>LspTexlabBuild<cr>", { desc = "Build Latex File" } },
        { "<localleader>lv", "<cmd>LspTexlabForward<cr>", { desc = "Forward Search" } },
        { "<localleader>ce", "<cmd>LspTexlabChangeEnvironment<cr>", { desc = "Change Environment" } },
        { "<localleader>lc", "<cmd>LspTexlabCleanAuxiliary<cr>", { desc = "Clean Aux" } },
    },
    settings = {
        texlab = {
            build = {
                onSave = true,
            },
            forwardSearch = {
                executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
                args = { "-g", "-r", "%l", "%p", "%f" },
            },
        },
    },
}

M["ruff"] = {
    enabled = true,
}

M["bashls"] = {
    enabled = true,
    filetypes = { "bash", "sh", "zsh" },
}

M["jsonls"] = {
    enabled = true,
    settings = {
        json = {
            schemas = {
                {
                    fileMatch = { "package.json" },
                    url = "https://json.schemastore.org/package.json",
                },
                {
                    fileMatch = { "tsconfig.json" },
                    url = "https://json.schemastore.org/tsconfig.json",
                },
            },
            validate = { enable = true },
        },
    },
}

return M
