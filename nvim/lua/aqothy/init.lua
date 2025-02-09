local is_vscode = vim.g.vscode

-- vscode or neovim
if is_vscode then
	require("aqothy.config.vscode")
else
	require("aqothy.config.options")
	require("aqothy.config.keymaps")
	require("aqothy.config.autocmds")
end

require("aqothy.config.lazy")

if not is_vscode then
	require("aqothy.config.statusline")

	vim.keymap.set("n", "<leader>pm", "<cmd>Lazy<CR>", { desc = "Open package manager" })
end
