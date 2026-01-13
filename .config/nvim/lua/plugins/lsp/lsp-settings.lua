local M = {}

local utils = require("custom.utils")
local lsp_util = require("lspconfig.util")

local map = vim.keymap.set

-- use enabled field to disable or enable a lsp
-- make sure to initialize the lsp even if you don't want custom config
-- since were not using mason-lspconfig it will not be initialized by default

-- npm install -g @typescript/native-preview
M["tsgo"] = {}

local jsts_config = {
    updateImportsOnFileMove = { enabled = "always" },
    preferences = {
        useAliasesForRenames = false,
    },
}

-- npm install -g @vtsls/language-server
M["vtsls"] = {
    enabled = false,
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
        map("n", "<localleader>ri", function()
            utils.action("source.addMissingImports.ts")
            vim.defer_fn(function()
                utils.action("source.organizeImports")
            end, 100)
        end, { buffer = bufnr, desc = "Refactor imports", silent = true })

        map("n", "<localleader>ru", function()
            utils.action("source.removeUnused.ts")
        end, { buffer = bufnr, desc = "Refractor unused", silent = true })
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
        "--function-arg-placeholders=0",
        "--fallback-style=WebKit",
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
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            completeUnimported = true,
        },
    },
    on_attach = function(_, bufnr)
        map("n", "<localleader>rf", function()
            utils.action("refactor.rewrite.fillStruct")
        end, { buffer = bufnr, desc = "Refactor Fill struct", silent = true })
    end,
}

-- uv tool install ty@latest
M["ty"] = {}

-- comes with macos
M["sourcekit"] = {
    filetypes = { "swift", "objc", "objcpp" },
}

-- uv tool install ruff@latest
M["ruff"] = {}

-- npm i -g @tailwindcss/language-server
M["tailwindcss"] = {
    root_dir = function(bufnr, on_dir)
        local root_files = {
            "tailwind.config.js",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.ts",
            "postcss.config.js",
            "postcss.config.cjs",
            "postcss.config.mjs",
            "postcss.config.ts",
        }
        local fname = vim.api.nvim_buf_get_name(bufnr)
        root_files = lsp_util.insert_package_json(root_files, "tailwindcss", fname)
        on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
    end,
}

-- npm i -g vscode-langservers-extracted
M["eslint"] = {}

M["jsonls"] = {
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

M["cssls"] = {}

return M
