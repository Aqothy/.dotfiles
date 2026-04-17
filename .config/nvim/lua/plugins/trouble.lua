return {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
        multiline = false,
        win = { position = "left" },
        max_items = 200000,
        icons = {
            kinds = require("config.icons").kinds,
        },
        modes = {
            lsp_document_symbols = {
                title = false,
                groups = false,
            },
        },
        keys = {
            [">"] = "fold_more",
            ["<"] = "fold_reduce",
            l = "fold_open",
            h = "fold_close",
        },
    },
    keys = function()
        local rep = require("custom.repeat")
        local function jump_trouble(direction)
            local trouble = require("trouble")
            if not trouble.is_open() then
                return false
            end

            local jump = direction == "next" and trouble.next or trouble.prev
            for _ = 1, vim.v.count1 do
                jump({ skip_groups = true, jump = true })
            end

            return true
        end

        local next_item, prev_item = rep.pair(function()
            if jump_trouble("next") then
                return
            end

            local ok, err = pcall(vim.cmd.cnext, { count = vim.v.count1 })
            if not ok then
                vim.notify(err, vim.log.levels.ERROR)
            end
        end, function()
            if jump_trouble("prev") then
                return
            end

            local ok, err = pcall(vim.cmd.cprevious, { count = vim.v.count1 })
            if not ok then
                vim.notify(err, vim.log.levels.ERROR)
            end
        end)

        return {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            { "<leader>cs", "<cmd>Trouble lsp_document_symbols toggle<cr>", desc = "Symbols (Trouble)" },
            { "<leader>cl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
            {
                "[q",
                prev_item,
                desc = "Previous Trouble/Quickfix Item",
            },
            {
                "]q",
                next_item,
                desc = "Next Trouble/Quickfix Item",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        }
    end,
}
