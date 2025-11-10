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
}

-- npm install -g @vtsls/language-server
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
    on_attach = function(_, bufnr)
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

-- brew install lua-language-server
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
        },
    },
}

-- comes with xcode cmdline tools
M["clangd"] = {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--fallback-style=WebKit",
    },
    init_options = {
        completeUnimported = true,
        clangdFileStatus = true,
    },
}

-- go install golang.org/x/tools/gopls@latest
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
        },
    },
    on_attach = function(_, bufnr)
        map("n", "<leader>rr", function()
            utils.action("refactor.rewrite.fillStruct")
        end, { buffer = bufnr, desc = "Fill Struct", silent = true })
    end,
}

-- uv tool install basedpyright
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

-- comes with macos
M["sourcekit"] = {
    filetypes = { "swift", "objc", "objcpp" },
}

M["hls"] = {
    root_dir = function(_, on_dir)
        on_dir(vim.fn.getcwd())
    end,
}

-- uv tool install ruff@latest
M["ruff"] = {}

return M
