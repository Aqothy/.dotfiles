local map = vim.keymap.set

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
map(
    "n",
    "<leader>nf",
    [[:e <C-R>=expand("%:p:h") . "/" <CR>]],
    { silent = false, desc = "Open a new file in the same directory" }
)
map("x", "@", function()
    vim.ui.input({ prompt = "Macro Register: " }, function(reg)
        vim.cmd([['<,'>normal @]] .. reg)
    end)
end, { silent = false })
map("n", "<leader>pv", vim.cmd.Ex, { desc = "NETRW" })
map("n", "<leader>si", function()
    vim.ui.input({ prompt = "How many spaces of indent?" }, function(input)
        -- User canceled the input
        if input == nil then
            return
        end

        local size = tonumber(input) or 4
        if not size then
            vim.notify("Please provide a number for indent size", vim.log.levels.ERROR)
            return
        end

        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = size
        vim.opt_local.tabstop = size
        vim.opt_local.softtabstop = size

        vim.notify(string.format("Set indent to %d for current buffer", size), vim.log.levels.INFO)
    end)
end)

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

-- Snippets
map("s", "<BS>", "<C-o>s", { desc = "Backspace to delete placeholder" })

map({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    vim.snippet.stop()
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

map({ "i", "s" }, "<C-l>", function()
    return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<C-l>"
end, { expr = true, desc = "Jump Next" })
map({ "i", "s" }, "<C-h>", function()
    return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<C-h>"
end, { expr = true, desc = "Jump Previous" })
