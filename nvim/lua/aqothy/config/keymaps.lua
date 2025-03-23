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
keymap("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
keymap("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- Line wrapping
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Editing and text manipulation
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("v", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("v", "<", "<gv", { desc = "Outdent and maintain selection" })
keymap({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Utility functions
keymap("n", "<leader>x", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
keymap("n", "<C-h>", "<cmd>silent !tmux neww ts<cr>", { desc = "New tmux session" }) -- need to be in tmux already for this to work
keymap("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {
	silent = false,
	desc = "Open a new file in the same directory",
})

keymap("n", "<leader>pm", "<cmd>Lazy<CR>", { desc = "Open package manager" })

-- lazygit
if vim.fn.executable("lazygit") == 1 then
	keymap("n", "<leader>gs", function()
		Snacks.lazygit()
	end, { desc = "Lazygit (cwd)" })
	keymap("n", "<leader>gl", function()
		Snacks.lazygit.log_file()
	end, { desc = "Git Log File" })
end

-- Toggle
Snacks.toggle
	.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
	:map("<leader>tl")

Snacks.toggle.dim():map("<leader>sd")
Snacks.toggle.diagnostics():map("<leader>td")
Snacks.toggle.zen():map("<leader>zz")
Snacks.toggle.profiler():map("<leader>pp")

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>sc")

Snacks.toggle({
	name = "Copilot",
	get = function()
		return not require("copilot.client").is_disabled()
	end,
	set = function(state)
		if state then
			require("copilot.command").enable()
		else
			require("copilot.command").disable()
		end
	end,
}):map("<leader>tc")

Snacks.toggle.treesitter():map("<leader>ts")

local tsc = require("treesitter-context")
Snacks.toggle({
	name = "Treesitter Context",
	get = tsc.enabled,
	set = function(state)
		if state then
			tsc.enable()
		else
			tsc.disable()
		end
	end,
}):map("<leader>tu")

Snacks.toggle({
	name = "Diffview",
	get = function()
		return require("diffview.lib").get_current_view() ~= nil
	end,
	set = function(state)
		vim.cmd("Diffview" .. (state and "Open" or "Close"))
	end,
}):map("<leader>gd")

Snacks.toggle({
	name = "Git Signs",
	get = function()
		return require("gitsigns.config").config.signcolumn
	end,
	set = function(state)
		require("gitsigns").toggle_signs(state)
	end,
}):map("<leader>tg")
