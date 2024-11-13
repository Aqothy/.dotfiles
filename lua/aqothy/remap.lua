vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pd", vim.cmd.Ex)
vim.keymap.set("n", "<leader>sv", "<C-w>v")
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>")
vim.keymap.set("n", "<leader>et", "<C-w>w", { desc = "Switch between NvimTree and editor" })