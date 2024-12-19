return {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Git blame", "Gvdiffsplit" },
    keys = { { "<leader>gs", "<cmd>Git<CR>", desc = "Open Git status" }, { "<leader>gg", "<cmd>Git blame<CR>", desc = "Git blame file" }, { "<leader>gd", "<cmd>Gvdiffsplit!<CR>", { desc = "Open Fugitive vertical diff" } } }, -- Load when this keymap is pressed
    -- event = "VeryLazy",
    config = function()
        -- Fugitive keymaps
        -- vim.keymap.set("n", "<leader>gg", "<cmd>Git Blame<CR>", { desc = "Git blame file" })
        -- vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Open Git status" })
        vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>", { desc = "Get left diff" })
        vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>", { desc = "Get right diff" })
        -- vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit!<CR>", { desc = "Open Fugitive vertical diff" })

        -- Auto commands for Fugitive buffers
        local fugitive_augroup = vim.api.nvim_create_augroup("fugitive_augroup", { clear = true })
        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = fugitive_augroup,
            pattern = "*",
            callback = function()
                if vim.bo.filetype ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }

                -- Keymaps specific to Fugitive buffers
                vim.keymap.set(
                    "n",
                    "<leader>p",
                    "<cmd>Git push<CR>",
                    vim.tbl_extend("keep", opts, { desc = "Git push" })
                )
                vim.keymap.set(
                    "n",
                    "<leader>P",
                    "<cmd>Git pull<CR>",
                    vim.tbl_extend("keep", opts, { desc = "Git pull" })
                )
                vim.keymap.set(
                    "n",
                    "<leader>t",
                    ":Git push -u origin ",
                    vim.tbl_extend("keep", opts, { desc = "Git push with tracking" })
                )
            end,
        })
    end,
}
