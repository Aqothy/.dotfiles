vim.g.mapleader = " "
vim.keymap.set("n", "<leader>sv", "<C-w>v")
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>")
vim.api.nvim_set_keymap("v", "cy", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "wq", ":q<CR>", { noremap = true, silent = true })
