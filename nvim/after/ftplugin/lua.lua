vim.keymap.set("n", "<leader>xx", function()
    vim.cmd.luafile("%")
    vim.notify("Sourced " .. vim.fn.expand("%"))
end, { desc = "Source current file", buffer = true })
