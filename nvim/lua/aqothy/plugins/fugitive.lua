return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>")
        vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>")
        vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>")
        --		vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit!<CR>", { desc = "Open Fugitive vertical diff" })
        local fugitive_augroup = vim.api.nvim_create_augroup("fugitive_augroup", {})
        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = fugitive_augroup,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false, desc = "Git push" }
                vim.keymap.set("n", "<leader>p", "<cmd>Git push<cr>", opts) -- push current branch

                vim.keymap.set(
                    "n",
                    "<leader>gp",
                    "<cmd>Git pull<cr>",
                    { buffer = bufnr, remap = false, desc = "git pull" }
                )

                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                vim.keymap.set(
                    "n",
                    "<leader>t",
                    ":Git push -u origin ",
                    { buffer = bufnr, remap = false, desc = "Git push origin" }
                )
            end,
        })
    end,
}
