-- -- Function to create a floating terminal
-- local function open_floating_terminal()
-- 	-- Get the current Neovim dimensions
-- 	local width = vim.api.nvim_get_option("columns")
-- 	local height = vim.api.nvim_get_option("lines")
--
-- 	-- Define floating window dimensions
-- 	local win_width = math.ceil(width * 0.7) -- 70% of screen width
-- 	local win_height = math.ceil(height * 0.7) -- 70% of screen height
-- 	local row = math.ceil((height - win_height) / 3) -- Centered vertically
-- 	local col = math.ceil((width - win_width) / 2) -- Centered horizontally
--
-- 	-- Create a new terminal buffer
-- 	local buf = vim.api.nvim_create_buf(false, true) -- No file, not listed
--
-- 	-- Set up options for the floating window
-- 	local opts = {
-- 		relative = "editor",
-- 		width = win_width,
-- 		height = win_height,
-- 		row = row,
-- 		col = col,
-- 		style = "minimal",
-- 		border = "rounded", -- Options: "single", "double", "rounded", "solid", "shadow"
-- 	}
--
-- 	-- Create the floating window
-- 	vim.api.nvim_open_win(buf, true, opts)
--
-- 	-- Start a terminal in the buffer
-- 	vim.fn.termopen(vim.o.shell)
--
-- 	-- Automatically enter insert mode after the terminal is created
-- 	vim.cmd("startinsert")
--
-- 	-- Optional: Set keybindings to close the terminal
-- 	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
-- end
--
-- -- Bind the function to a command
-- vim.api.nvim_create_user_command("FloatingTerm", open_floating_terminal, {})

local set = vim.opt_local

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		set.number = false
		set.relativenumber = false
		set.scrolloff = 0

		vim.bo.filetype = "terminal"
	end,
})

-- Open a terminal at the bottom of the screen with a fixed height.
vim.keymap.set("n", "<C-t>", function()
	vim.cmd.new()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 15)
	vim.cmd.term()
end)
