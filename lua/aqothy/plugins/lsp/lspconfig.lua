return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup_handlers({
        
        function(server_name)
            lspconfig[server_name].setup({
            capabilities = capabilities,
            })
        end,

        ["emmet_ls"] = function()
            -- configure emmet language server
            lspconfig["emmet_ls"].setup({
            capabilities = capabilities,
            filetypes = { "html", "typescriptreact", "javascriptreact", "css" },
            })
        end,

        ["lua_ls"] = function()
            -- configure lua server (with special settings)
            lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                -- make the language server recognize "vim" global
                diagnostics = {
                    globals = { "vim" },
                },
                completion = {
                    callSnippet = "Replace",
                },
                },
            },
            })
        end,
        
    })
  end,
}
