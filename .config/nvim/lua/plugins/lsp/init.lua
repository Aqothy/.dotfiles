return {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    cmd = "LspInfo",
    -- stylua: ignore
    keys = {
        { "<leader>lc", function() Snacks.picker.lsp_config() end, desc = "Lsp config" },
    },
    config = vim.schedule_wrap(function()
        local handlers = require("plugins.lsp.lsp-handlers")
        local utils = require("custom.utils")

        handlers.setup()

        local lsp_group = vim.api.nvim_create_augroup("aqothy/lspconfig", { clear = true })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = lsp_group,
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)

                if not client then
                    return
                end

                handlers.on_attach(client, ev.buf)
            end,
        })

        ---@diagnostic disable-next-line: duplicate-set-field
        vim.lsp.start = (function(overridden)
            return function(config, opts)
                if opts and opts.bufnr then
                    local bufnr = opts.bufnr
                    if not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    -- prevent lsp from attaching to artificial buffers, ref: https://github.com/neovim/neovim/issues/32074
                    if not utils.bufname_valid(bufname) then
                        return
                    end
                end
                return overridden(config, opts)
            end
        end)(vim.lsp.start)

        local params = {
            capabilities = handlers.capabilities,
        }

        -- global capabilities, lspconfig, personal config in order of increasing priority
        vim.lsp.config("*", params)

        local settings = require("plugins.lsp.lsp-settings")
        for lsp, user_opts in pairs(settings) do
            if user_opts.enabled ~= false then
                local opts = vim.deepcopy(user_opts)

                local user_on_attach = opts.on_attach

                if user_on_attach then
                    local default_on_attach = vim.lsp.config[lsp].on_attach

                    opts.on_attach = function(client, bufnr)
                        if default_on_attach then
                            default_on_attach(client, bufnr)
                        end
                        user_on_attach(client, bufnr)
                    end
                end

                vim.lsp.config(lsp, opts)
                vim.lsp.enable(lsp)
            end
        end
    end),
}
