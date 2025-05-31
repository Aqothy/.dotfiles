local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<leader>sf", function()
    vim.cmd.luafile("%")
    vim.notify("Sourced " .. vim.fn.expand("%"))
end, { desc = "Source current file", buffer = bufnr })
