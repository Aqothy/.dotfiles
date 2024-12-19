return {
    "zbirenbaum/copilot.lua",
    -- lazy = false,
    event = "InsertEnter",
    config = function()
        vim.keymap.set("i", "<Tab>", function()
            if require("copilot.suggestion").is_visible() then
                require("copilot.suggestion").accept()
            else
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
            end
        end, {
            silent = true,
        })
        require("copilot").setup({
            panel = {
                keymap = {
                    jump_next = "<C-n>",
                    jump_prev = "<C-p>",
                    accept = "<C-enter>",
                    refresh = "r",
                },
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = false,
                    next = "<C-n>",
                    prev = "<C-p>",
                    dismiss = "<C-H>",
                },
                filetypes = {
                    yaml = true,
                    markdown = true,
                    help = false,
                    ["leetcode.nvim"] = false,
                },
            },
        })
        vim.api.nvim_set_keymap(
            "n",
            "<c-s>",
            ":lua require('copilot.suggestion').toggle_auto_trigger()<CR>",
            { noremap = true, silent = true }
        )
    end,
}
