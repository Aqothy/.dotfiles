local keymap = vim.keymap.set

-- Window management
keymap("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" })

-- Navigation and movement
keymap("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
keymap("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
keymap("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })

-- Editing and text manipulation
keymap({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("x", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("x", "<", "<gv", { desc = "Outdent and maintain selection" })

-- Utils
keymap("n", "<leader>xc", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
keymap("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false, desc = "Open a new file in the same directory" })
keymap("n", "<leader>ip", vim.show_pos, { desc = "Inspect Pos" })
keymap("n", "<leader>it", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })
keymap("n", "<leader>pm", "<cmd>Lazy<CR>", { desc = "Open package manager" })
keymap("x", "@", function()
    vim.ui.input({ prompt = "Macro Register: " }, function(reg)
        vim.cmd([['<,'>normal @]] .. reg)
    end)
end, { silent = false })
keymap("n", "<leader>pv", vim.cmd.Ex, { desc = "NETRW" })
keymap("n", "<leader>xx", function()
    local success, err =
        pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.diagnostic.setqflist)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Toggle Diagnostic Quickfix List" })
keymap("n", "<leader>qq", function()
    local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Quickfix List" })

-- "Whole Buffer" text-object:
keymap("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
keymap("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })
