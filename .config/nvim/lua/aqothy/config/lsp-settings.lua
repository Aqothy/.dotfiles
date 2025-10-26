local M = {}

local utils = require("aqothy.config.utils")

local map = vim.keymap.set

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

local jsts_config = {
    updateImportsOnFileMove = { enabled = "always" },
    tsserver = {
        nodePath = "/Users/aqothy/.local/bin/npc.sh",
    },
    suggest = {
        completeFunctionCalls = true,
    },
}

local base_vtsls_on_attach = vim.lsp.config.vtsls.on_attach

M["vtsls"] = {
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
    on_attach = function(client, bufnr)
        if base_vtsls_on_attach then
            base_vtsls_on_attach(client, bufnr)
        end

        map("n", "<leader>oi", function()
            utils.action("source.addMissingImports.ts")
            vim.defer_fn(function()
                utils.action("source.organizeImports")
            end, 100)
        end, { buffer = bufnr, desc = "Organize Imports", silent = true })

        map("n", "<leader>rm", function()
            utils.action("source.removeUnused.ts")
        end, { buffer = bufnr, desc = "Remove Unused", silent = true })
    end,
}

M["lua_ls"] = {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                version = "LuaJIT",
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },
            },
        })
    end,

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

local base_gopls_on_attach = vim.lsp.config.gopls.on_attach

M["gopls"] = {
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
    on_attach = function(client, bufnr)
        if base_gopls_on_attach then
            base_gopls_on_attach(client, bufnr)
        end

        map("n", "<leader>rr", function()
            utils.action("refactor.rewrite.fillStruct")
        end, { buffer = bufnr, desc = "Fill Struct", silent = true })
    end,
}

M["basedpyright"] = {
    settings = {
        basedpyright = {
            disableOrganizeImports = true,
            analysis = {
                typeCheckingMode = "standard",
            },
        },
    },
}

M["sourcekit"] = {
    filetypes = { "swift", "objc", "objcpp" },
}

local base_texlab_on_attach = vim.lsp.config.texlab.on_attach

M["texlab"] = {
    settings = {
        texlab = {
            forwardSearch = {
                executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
                args = { "-g", "-r", "%l", "%p", "%f" },
            },
        },
    },
    on_attach = function(client, bufnr)
        if base_texlab_on_attach then
            base_texlab_on_attach(client, bufnr)
        end

        -- stylua: ignore start
        map("n", "<localleader>ll", "<cmd>LspTexlabBuild<cr>", { buffer = bufnr, desc = "Build Latex File", silent = true })
        map("n", "<localleader>lv", "<cmd>LspTexlabForward<cr>", { buffer = bufnr, desc = "Forward Search", silent = true })
        map("n", "<localleader>lc", "<cmd>LspTexlabCleanAuxiliary<cr>", { buffer = bufnr, desc = "Clean Aux", silent = true })
        -- stylua: ignore end
    end,
}

M["hls"] = {
    root_dir = function(_, on_dir)
        on_dir(vim.fn.getcwd())
    end,
}

M["ruff"] = {}

return M
