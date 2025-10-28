return {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    cmd = "LspInfo",
    keys = {
        { "<leader>li", function() Snacks.picker.lsp_config() end, desc = "Lsp info" },
    },
    config = vim.schedule_wrap(function()
        local handlers = require("aqothy.config.lsp-handlers")

        handlers.setup()

        local lsp_group = vim.api.nvim_create_augroup("aqothy/lspconfig", { clear = true })

        vim.api.nvim_create_autocmd("LspProgress", {
            group = lsp_group,
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)

                if not client then
                    return
                end

                local params = ev.data.params
                local value = params.value

                local is_end = value.kind == "end"

                vim.notify(value.title, vim.log.levels.INFO, {
                    id = client.id .. "-" .. params.token,
                    title = client.name,
                    timeout = is_end and 1000 or 0,
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
            capabilities = handlers.capabilities,
        }

        -- global capabilities, lspconfig, personal config in order of increasing priority
        vim.lsp.config("*", params)

        local settings = require("aqothy.config.lsp-settings")
        for lsp, opts in pairs(settings) do
            if opts.enabled ~= false then
                vim.lsp.config(lsp, opts)
                vim.lsp.enable(lsp)
            end
        end
    end),
}
