return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local lspconfig = require("lspconfig")

        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local builtin = require("telescope.builtin")

        local mason_lspconfig = require("mason-lspconfig")

        -- Keymaps for LSP
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),

            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }
                local id = vim.tbl_get(ev, 'data', 'client_id')
                local client = id and vim.lsp.get_client_by_id(id)
                if client == nil then
                    return
                end

                if client.supports_method("textDocument/formatting") then
                    -- look at lsp zero for more info
                    -- key map for manual formatting
                    -- vim.keymap.set({'n', 'x'}, '<leader>k', function()
                    --   vim.lsp.buf.format({async = false, timeout_ms = 3000})
                    -- end, opts)

                    -- Format the current buffer on save
                    local group = 'lsp_autoformat'
                    vim.api.nvim_create_augroup(group, { clear = false })
                    vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })
                    vim.api.nvim_create_autocmd('BufWritePre', {
                        buffer = ev.buf,
                        group = group,
                        desc = 'LSP format on save',
                        callback = function()
                            -- note: do not enable async formatting
                            vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
                        end,
                    })
                end

                if client.supports_method("textDocument/inlayHint") then
                    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                end

                -- Key mappings for LSP functions
                vim.keymap.set("n", "<leader>ld", builtin.lsp_definitions, opts) -- show lsp definitions
                vim.keymap.set("n", "<leader>lt", builtin.lsp_type_definitions, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>fd", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "<leader>lr", builtin.lsp_references, opts)
                vim.keymap.set("n", "]d", function()
                    vim.diagnostic.goto_next({ float = false })
                end, opts)
                vim.keymap.set("n", "[d", function()
                    vim.diagnostic.goto_prev({ float = false })
                end, opts)
            end,
        })

        -- LSP server setup
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_nvim_lsp.default_capabilities()
        )

        mason_lspconfig.setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,
            ["lua_ls"] = function()
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
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
            ["clangd"] = function()
                lspconfig["clangd"].setup({
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--fallback-style=LLVM",
                    },
                })
            end,
            ["pyright"] = function()
                lspconfig["pyright"].setup({
                    capabilities = capabilities,
                    settings = {
                        python = {
                            analysis = {
                                -- TODO: It would be nice to understand this better and turn these back on someday.
                                reportMissingTypeStubs = false,
                                typeCheckingMode = "off",
                            },
                        },
                    },
                })
            end,
            ["emmet_ls"] = function()
                -- configure emmet language server
                lspconfig["emmet_ls"].setup({
                    capabilities = capabilities,
                    filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss" },
                })
            end,
        })

        -- Diagnostics Configuration
        vim.diagnostic.config({
            virtual_text = true,
            underline = true,
            -- update_in_insert = false,
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}
