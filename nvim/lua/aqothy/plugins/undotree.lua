return {
	-- undo tree in lua
	"jiaoshijie/undotree",
	keys = { -- load the plugin only when using it's keybinding:
		{ "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
	},
	config = function()
		require("undotree").setup()
	end,
}
