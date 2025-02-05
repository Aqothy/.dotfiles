local vscode = require('vscode')

vim.g.mapleader = " "
vim.g.maplocalleader = " "
local keymap = vim.keymap.set

vim.notify = vscode.notify

vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.virtualedit = 'block'
vim.opt.wildmode = 'longest:full,full' -- Command-line completion mode

keymap('n', '<tab>', '<Cmd>Tabnext<CR>')
keymap('n', '<S-tab>', '<Cmd>Tabprevious<CR>')
keymap('n', '<leader>w', '<Cmd>Tabclose<CR>')

keymap({ 'n', 'x' }, '<C-h>', function() vscode.action('workbench.action.navigateLeft') end, { silent = true })
keymap({ 'n', 'x' }, '<C-j>', function() vscode.action('workbench.action.navigateDown') end, { silent = true })
keymap({ 'n', 'x' }, '<C-k>', function() vscode.action('workbench.action.navigateUp') end, { silent = true })
keymap({ 'n', 'x' }, '<C-l>', function() vscode.action('workbench.action.navigateRight') end, { silent = true })

-- better up/down
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

keymap('n', '<leader>nf', function() vscode.call('workbench.action.files.newUntitledFile') end, {
  desc = 'New file',
})

keymap('n', '<leader>ff', function() vscode.call('workbench.action.quickOpen') end, {
  desc = 'Open file finder',
})

keymap('n', '<leader>fs', function() vscode.call('workbench.action.findInFiles') end, {
  desc = 'Search in files',
})
