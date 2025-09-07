return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile", "BufWritePre" },
    cmd = "LspInfo",
    keys = {
        { "<leader>li", function() Snacks.picker.lsp_config() end, desc = "Lsp info" },
    },
    config = function()
        local handlers = require("aqothy.config.lsp-handlers")

        handlers.setup()

        local lsp_group = vim.api.nvim_create_augroup("aqothy/lspconfig", { clear = true })

        vim.api.nvim_create_autocmd("LspProgress", {
            group = lsp_group,
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                local value = ev.data.params.value
                if not client then
                    return
                end

                local is_end = value.kind == "end"

                vim.notify(value.title, vim.log.levels.INFO, {
                    id = client.name .. client.id,
                    title = client.name,
                    timeout = is_end and 3000 or 0,
                    opts = function(notif)
                        notif.icon = is_end and "" or "󱥸"
                    end,
                })
            end,
        })

        local utils = require("aqothy.config.utils")

        vim.api.nvim_create_autocmd("LspAttach", {
            group = lsp_group,
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)

                if not client then
                    return
                end

                local file = ev.file

                -- prevent lsp from attaching to artificial buffers, ref: https://github.com/neovim/neovim/issues/32074
                if #file ~= 0 and not utils.bufname_valid(file) then
                    client:stop()
                    return
                end

                handlers.on_attach(client, ev.buf)
            end,
        })

        local params = {
            capabilities = handlers.get_capabilities(),
        }

        -- global capabilities, lspconfig, peronal config in order of increasing priority
        vim.lsp.config("*", params)

        local settings = require("aqothy.config.lsp-settings")
        for lsp, opts in pairs(settings) do
            if opts.enabled ~= false then
                vim.lsp.config(lsp, opts)
                vim.lsp.enable(lsp)
            end
        end
    end,
}
