return {
	"zbirenbaum/copilot.lua",
	build = ":Copilot auth",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			panel = { enabled = false },
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<C-enter>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-g>",
				},
			},
			filetypes = {
				["*"] = true,
				["leetcode.nvim"] = false,
			},
			-- TODO: Prob need to change in the future in new setup since nvm will be installed thru brew
			copilot_node_command = "/Users/aqothy/.nvm/versions/node/v20.12.2/bin/node",
		})
		-- vim.keymap.set("i", "<Tab>", function()
		-- 	if require("copilot.suggestion").is_visible() then
		-- 		require("copilot.suggestion").accept()
		-- 	else
		-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
		-- 	end
		-- end, {
		-- 	silent = true,
		-- })
	end,
}
