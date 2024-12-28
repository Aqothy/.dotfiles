return {
    "zbirenbaum/copilot.lua",
    -- lazy = false,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
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
                    accept = "<C-enter>",
                    next = "<C-n>",
                    prev = "<C-p>",
                    dismiss = "<C-H>",
                },
            },
            filetypes = {
                yaml = true,
                markdown = true,
                ["leetcode.nvim"] = false,
            },
            copilot_node_command = "/Users/aqothy/.nvm/versions/node/v20.12.2/bin/node"
        })
        -- vim.keymap.set("i", "<Tab>", function()
        --     if require("copilot.suggestion").is_visible() then
        --         require("copilot.suggestion").accept()
        --     else
        --         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        --     end
        -- end, {
        --     silent = true,
        -- })

        vim.api.nvim_set_keymap(
            "n",
            "<c-s>",
            ":lua require('copilot.suggestion').toggle_auto_trigger()<CR>",
            { noremap = true, silent = true }
        )
    end,
}
