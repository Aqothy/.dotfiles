return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")
    
    local mason_tool_installer = require("mason-tool-installer")
    
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
            "typescript-language-server",
        },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "pylint",
        "eslint_d",
      },
    })

  end,
}