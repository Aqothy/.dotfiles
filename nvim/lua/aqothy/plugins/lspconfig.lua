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

        ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
        local progress = vim.defaulttable()
        vim.api.nvim_create_autocmd("LspProgress", {
            group = vim.api.nvim_create_augroup("lsp_progress", { clear = true }),
            ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
                if not client or type(value) ~= "table" then
                    return
                end
                local p = progress[client.id]

                for i = 1, #p + 1 do
                    if i == #p + 1 or p[i].token == ev.data.params.token then
                        p[i] = {
                            token = ev.data.params.token,
                            msg = ("[%3d%%] %s%s"):format(
                                value.kind == "end" and 100 or value.percentage or 100,
                                value.title or "",
                                value.message and (" **%s**"):format(value.message) or ""
                            ),
                            done = value.kind == "end",
                        }
                        break
                    end
                end

                local msg = {} ---@type string[]
                progress[client.id] = vim.tbl_filter(function(v)
                    return table.insert(msg, v.msg) or not v.done
                end, p)

                local is_end = value.kind == "end"

                local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, {
                    id = client.name .. client.id,
                    title = client.name,
                    timeout = is_end and 3000 or 0,
                    opts = function(notif)
                        notif.icon = #progress[client.id] == 0 and " "
                            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                    end,
                })
            end,
        })

        local utils = require("aqothy.config.utils")

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("aqothy/lsp_attach", { clear = true }),
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
    end,
}
