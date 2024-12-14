return
{
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        --            "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    cmd = "Mason",
    config = function()
        local mason = require("mason")
        -- local mason_tool_installer = require("mason-tool-installer")

        -- import mason-lspconfig
        local mason_lspconfig = require("mason-lspconfig")

        mason.setup()

        mason_lspconfig.setup({
            -- list of servers for mason to install
            ensure_installed = {
                "html",
                "cssls",
                "tailwindcss",
                "lua_ls",
                "emmet_ls",
                "pyright",
                "clangd",
                "gopls",
                "jdtls",
                "texlab",
                "eslint",
                -- "typescript-language-server", -- just manually download on mason, dk why its broken
            },
        })

        -- mason_tool_installer.setup({
        -- 	ensure_installed = {
        -- 		"prettierd", -- prettier formatter
        -- 		"stylua", -- lua formatter
        -- 		"black", -- python formatter
        -- 		--"eslint_d",
        -- 		--"latexindent",
        -- 		--"clang-format",
        -- 		"gofumpt",
        -- 		"goimports-reviser",
        -- 		"golines",
        -- 	},
        -- })
    end,
}
