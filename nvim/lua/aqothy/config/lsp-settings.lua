local M = {}

local utils = require("aqothy.config.utils")

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

M["eslint"] = {
    enabled = false,
    settings = {
        -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
        workingDirectories = { mode = "auto" },
        format = false,
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
    tsserver = {
        nodePath = "~/.local/bin/npc",
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
                    entriesLimit = 30,
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
            analysis = {
                typeCheckingMode = "standard",
            },
        },
    },
}

M["sourcekit"] = {
    enabled = true,
    filetypes = { "swift", "objc", "objcpp" },
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

return M
