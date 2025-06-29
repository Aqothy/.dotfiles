local map = vim.keymap.set

-- Window management
map("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" })

-- Navigation and movement
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
map("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
map("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })

-- Add to jumplist when jumping with j and k with count and wrap
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Editing and text manipulation
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })

-- Utils
map("n", "<leader>xc", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
map("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false, desc = "Open a new file in the same directory" })
map("n", "<leader>ip", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>it", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })
map("n", "<leader>pm", "<cmd>Lazy<CR>", { desc = "Open package manager" })
map("x", "@", function()
    vim.ui.input({ prompt = "Macro Register: " }, function(reg)
        vim.cmd([['<,'>normal @]] .. reg)
    end)
end, { silent = false })
map("n", "<leader>pv", vim.cmd.Ex, { desc = "NETRW" })
map("n", "<leader>om", function()
    if vim.o.diffopt:find("linematch") ~= nil then
        vim.opt.diffopt:remove({ "linematch:60" })
        vim.notify("remove linematch", vim.log.levels.INFO)
    else
        vim.opt.diffopt:append({ "linematch:60" })
        vim.notify("append linematch", vim.log.levels.INFO)
    end
end, { desc = "Toggle linematch in diffopt" })

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })
