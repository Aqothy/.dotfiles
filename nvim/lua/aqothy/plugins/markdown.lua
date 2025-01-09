return {
	-- {
	-- 	"OXY2DEV/markview.nvim",
	-- 	ft = "markdown", -- If you decide to lazy-load anyway
	-- 	-- dependencies = {
	-- 	-- "nvim-treesitter/nvim-treesitter",
	-- 	-- "nvim-tree/nvim-web-devicons"
	-- 	-- },
	-- 	config = function()
	-- 		require("markview").setup({
	-- 			initial_state = true,
	-- 			hybrid_modes = { "n" },
	-- 		})
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<leader>mk",
	-- 			"<cmd>Markview splitToggle<CR>",
	-- 			{ desc = "Open split view for Markdown preview" }
	-- 		)
	-- 	end,
	-- },
	-- {
	-- 	"iamcco/markdown-preview.nvim",
	-- 	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	-- 	build = function()
	-- 		vim.fn["mkdp#util#install"]()
	-- 	end,
	-- 	keys = {
	-- 		{
	-- 			"<leader>mm",
	-- 			ft = "markdown",
	-- 			"<cmd>MarkdownPreviewToggle<cr>",
	-- 			desc = "Markdown Preview",
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		vim.cmd([[do FileType]])
	-- 	end,
	-- },
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			bullet = {
				-- Turn on / off list bullet rendering
				enabled = true,
			},
			checkbox = {
				-- Turn on / off checkbox state rendering
				enabled = true,
				-- Determines how icons fill the available space:
				--  inline:  underlying text is concealed resulting in a left aligned icon
				--  overlay: result is left padded with spaces to hide any additional text
				position = "inline",
				unchecked = {
					-- Replaces '[ ]' of 'task_list_marker_unchecked'
					icon = "   󰄱 ",
					-- Highlight for the unchecked icon
					highlight = "RenderMarkdownUnchecked",
					-- Highlight for item associated with unchecked checkbox
					scope_highlight = nil,
				},
				checked = {
					-- Replaces '[x]' of 'task_list_marker_checked'
					icon = "   󰱒 ",
					-- Highlight for the checked icon
					highlight = "RenderMarkdownChecked",
					-- Highlight for item associated with checked checkbox
					scope_highlight = nil,
				},
			},
			html = {
				-- Turn on / off all HTML rendering
				enabled = true,
				comment = {
					-- Turn on / off HTML comment concealing
					conceal = false,
				},
			},
			heading = {
				sign = false,
				icons = { " 󰎤 ", " 󰎧 ", " 󰎪 ", " 󰎭 ", " 󰎱 ", " 󰎳 " },
			},
		},
		ft = { "markdown" },
		config = function(_, opts)
			require("render-markdown").setup(opts)
			Snacks.toggle({
				name = "Render Markdown",
				get = function()
					return require("render-markdown.state").enabled
				end,
				set = function(enabled)
					local m = require("render-markdown")
					if enabled then
						m.enable()
					else
						m.disable()
					end
				end,
			}):map("<leader>mm")
		end,
	},
}
