local M = {}

local utils = require("aqothy.config.utils")

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

local jsts_config = {
    updateImportsOnFileMove = { enabled = "always" },
    tsserver = {
        nodePath = "/Users/aqothy/.local/bin/npc",
    },
    suggest = {
        completeFunctionCalls = true,
    },
}

M["vtsls"] = {
    enabled = true,
    settings = {
        vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
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
            workspace = {
                checkThirdParty = false,
            },
            doc = {
                privateName = { "^_" },
            },
            completion = {
                callSnippet = "Replace",
            },
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
        "--fallback-style=WebKit",
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
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            completeUnimported = true,
            usePlaceholders = true,
            staticcheck = true,
        },
    },
    keys = {
        {
            "<leader>rr",
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
        { "<localleader>lc", "<cmd>LspTexlabCleanAuxiliary<cr>", { desc = "Clean Aux" } },
    },
    settings = {
        texlab = {
            forwardSearch = {
                executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
                args = { "-g", "-r", "%l", "%p", "%f" },
            },
        },
    },
}

M["hls"] = {
    enabled = true,
    root_dir = function(_, on_dir)
        on_dir(vim.fn.getcwd())
    end,
}

return M
