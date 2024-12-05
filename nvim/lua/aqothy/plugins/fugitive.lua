return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", function()
			vim.cmd("vertical Git") -- Open Git in a vertical split
			vim.cmd("wincmd H") -- Move the vertical split to the left
			vim.cmd("vertical resize 50") -- Set the split width to 50 columns
		end, { desc = "Open Git status on the left with width 50" })
		vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
		vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")
		vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit!<CR>", { desc = "Open Fugitive vertical diff" })
	end,
}
