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

        local utils = require("aqothy.config.utils")

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("aqothy/lsp_attach", { clear = true }),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)

                if not client or string.find(client.name:lower(), "copilot") then
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
    end,
}
