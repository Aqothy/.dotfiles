local user = require("aqothy.config.user")
local utils = require("aqothy.config.utils")

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
		dashboard = {

			enabled = false,

			preset = {

                -- stylua: ignore
				keys = {
					{ icon = " ", key = "SPC gs", desc = "Git", action = "<cmd>lua require('snacks').lazygit()<cr>" },
					{ icon = " ", desc = "Browse Repo", key = "SPC gh", action = function() Snacks.gitbrowse() end },
					{ icon = "󰱼 ", key = "SPC ff", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "SPC fs", desc = "Find Word", action = ":lua Snacks.dashboard.pick('live_grep')" },
					{
						icon = " ",
						key = "SPC ee",
						desc = "File Explorer",
						action = function()
							require("mini.files").open(vim.uv.cwd(), true)
						end,
					},
                    { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "q", desc = "Quit NVIM", action = "<cmd>qa<CR>" },
				},

				-- header = [[
				--               ⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⢠⣿⣄⣤⣤⣤⣤⣼⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⣠⣾⣿⣻⡵⠖⠛⠛⠛⢿⣿⣶⣴⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠏⢷⡄⠀⠀⠀
				--  ⠀⣤⣤⡾⣯⣿⡿⠋⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣷⣤⣴⣾⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠏⠀⠈⢻⣦⡀⠀
				--  ⠀⢹⣿⣴⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣄⡀⢀⣤⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⠀⠈⠻⣦⠀⠀⣼⠋⠀⠀
				--  ⠀⣼⢉⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣥⠤⠴⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⠿⣿⣿⣿⣿⡇⣸⠋⠻⣿⣷
				--  ⢰⡏⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣶⣶⣿⣟⣿⣟⣛⣭⣉⣩⣿⣿⡀⣼⣿⣿⣿⣿⣿⣄⠀⣸⣿
				--  ⢿⡇⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⠿⠿⠛⠛⠛⠛⠛⠻⣿⣿⣭⣉⢉⣿⣿⠟⣰⣿⡟
				--  ⠈⣷⠸⣇⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠞⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠀⠀⠉⣿⣿⡏⢀⣿⡟⠀
				--  ⠀⠹⣦⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣀⠀⠀⠀⠀⣼⣿⡿⢫⣿⣿⡁⠀
				--  ⠀⠀⠀⠙⣿⡿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⠿⢯⡈⠙⣧⡀⠀⠀⣿⣄⣴⣿⣿⠉⠻⣦
				--  ⠀⠀⠀⠰⠿⠛⠛⠻⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⣴⠏⠀⠀⠀⠀⠀⠀⠀⣰⣿⠉⠀⠀⠀⠚⣷⠀⠘⡇⠀⠀⠀⠙⠛⠉⠁⠀⠀⠈
				--  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⣿⣽⡿⣿⣷⣦⣀⠀⠀⢰⡟⠀⠀⠀⠀⠀⠀⠀⠀⣿⠽⣄⠀⠀⠀⣠⠟⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠙⠻⣿⣿⣟⣷⣦⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠛⢧⡉⠛⠛⠛⠁⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡟⢉⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠳⠶⠶⠶⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠈⠉⠉⠉⣻⣿⣇⡀⠀⠀⠀⠀⠀⣤⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢷⣄⠀⣠⣾⡿⠁⠙⢷⣦⣦⣤⣴⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠀⠀⢀⣴⠶⣆⠀⠀⠀⣾⠉⢻⣿⣿⡀⠀⠀⢿⣿⢉⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠀⢀⣿⠁⢠⡟⠀⠀⠀⣿⠀⠘⣯⠉⠃⠀⠀⠈⢁⣸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⣀⣼⡿⠀⠘⣷⠀⠀⠀⣿⠀⠀⢻⡶⠞⢛⡶⠚⢻⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⢀⡾⠋⠁⣀⠀⠀⠈⠳⣄⠀⢸⡆⠀⠈⢷⣄⠟⢁⣠⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡇⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⢸⡇⠀⠀⠈⢻⡄⠀⠀⠘⢷⣤⣷⡀⠀⠀⠙⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⣧⠀⠀⠀⠀⣿⡀⠀⠀⠀⠈⢻⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣇⠀⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⢹⣄⠀⠀⢀⣿⠁⡀⠀⠀⠀⠀⠻⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀
				--  ⠀⠀⠀⠀⠀⠉⠛⠛⠛⠉⠻⣿⡦⠀⠀⠀⠀⠈⢻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡇⠀⠀⠀⠀⠀⠀
				--                  ]],

				header = [[
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣤⣴⣶⣶⣶⣶⣶⣶⣤⣤⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠛⠛⠛⠛⠛⠛⠛⠛⠛⠻⠿⠿⠿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⢉⣉⣤⣤⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⣙⣛⡿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⡿⠟⠋⢁⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣾⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⡿⠛⠀⢀⣤⣿⣿⣿⣿⣿⣿⡿⠟⠛⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⡿⠋⠀⠀⣴⣿⣿⣿⣿⣿⣿⠟⠉⠀⠀⠀⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠋⢹⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⠋⠀⠀⢠⣾⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⠀⠀⣄⠀⠀⠀⢠⣾⣿⣿⣿⡿⠁⠀⠈⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢠⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠈⢿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⠀⢀⡿⠀⠀⠀⢸⣿⣿⣿⠏⠀⠀⠀⠀⠙⠿⠟⢹⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢠⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠋⢁⣠⡾⠁⠀⠀⠀⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣠⠿⠛⠛⠻⢿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠁⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⣤⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⣤⣤⣤⣤⣴⣶⠶⠶⠶⠶⡦⠀⠀⠈⠛⢷⣦⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⢛⣿⣿⡟⠋⠛⣻⣿⣿⡟⠛⠛⠛⠛⠛⠛⠛⠁⠀⠀⠀⠀⢨⣿⣿⣟⣉⣛⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠿⣿⣿⣿⠿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠛⠛⠛⠉⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠷⣤⣤⣄⣀⣤⣤⣤⣶⠞⠻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡇
⠀⢀⣀⣤⣴⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠠⠬⠀⠀⠀⠾⢯⣙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇
⣿⣿⣟⡿⣽⣻⣟⡿⣷⣶⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣄⢹⡎⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠇
⣟⡷⣯⣟⣷⣻⢾⣽⣳⢯⣟⣿⣻⢿⣷⣶⣦⣤⣤⣀⡀⠀⠀⠀⠀⢸⠏⢿⠀⠈⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠀
⡾⣽⣳⣟⡾⣭⣟⡾⣽⣻⣞⡷⣯⣟⡾⣽⢯⣟⣿⣻⣿⣿⣶⣶⣤⠋⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡇⠀
⣽⢳⡟⣾⣽⢳⣯⡟⣷⢻⣾⣽⢳⣯⣿⣽⢻⡞⣷⢻⣿⡞⣷⣯⣿⣶⣤⠀⠀⠀⣴⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠀⠀
⢯⡿⣽⣳⢯⣟⡾⣽⢯⣟⡾⣽⣻⣞⡷⣯⢿⡽⢯⣟⣿⣟⣷⣻⢾⣽⣻⣷⠀⣰⣿⣷⣤⣤⣀⠀⠀⠀⣀⣠⣤⣤⣤⣄⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠟⠀⠀⠀
⡿⣽⣳⢯⣟⡾⣽⢯⣟⡾⣽⣳⣟⡾⣽⢯⣟⣾⣻⢾⣽⣻⣷⣯⣿⣾⣷⣿⣿⢿⣿⡿⣽⢯⣿⡟⠶⢦⣄⣹⣷⠌⡜⢻⣯⣙⠻⢷⣤⡀⠀⠀⠀⠀⣀⣴⠟⠁⠀⠀⠀⠀
⣽⣳⢯⣟⡾⣽⢯⣟⡾⣽⣳⣟⡾⣽⢯⣟⣾⣳⢯⣟⣾⣳⢯⡿⣽⣳⢯⡷⣯⣿⣿⣻⣽⣻⢾⡇⠀⠀⠈⠙⢿⡞⣌⢣⢚⣿⡕⡎⡜⡻⣦⣠⣴⡾⠛⠁⠀⠀⠀⠀⠀⠀
⡾⣽⣻⢾⡽⣯⣟⡾⣽⣳⣟⡾⣽⢯⣟⣾⣳⢯⣟⣾⣳⢯⡿⣽⣳⢯⡿⣽⣳⣿⣯⢷⣯⡽⣿⠁⠀⠀⠀⠀⠘⣿⠤⣃⠎⡼⣿⢜⡰⢱⡙⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣽⣳⢯⡿⣽⣳⢯⣟⣷⣻⣾⣿⣿⣿⣞⡷⣯⣟⣾⣳⢯⡿⣽⣳⢯⡿⣽⣳⣿⡿⣞⣿⣺⣽⡟⠀⠀⠀⠀⠀⠀⢻⣧⢃⠞⣰⠡⢎⠲⣅⠚⣼⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠷⠿⠿⢿⣷⣯⣟⣾⣳⣟⣾⣳⣟⣾⣻⢿⣷⣿⣾⡽⣯⣟⡷⣯⢿⣽⣳⣿⣿⣽⣻⣞⡷⣿⠃⠀⠀⠀⠀⠀⠀⠈⠻⣯⣜⢢⡙⣌⠳⡌⢳⣴⡟⠀⠀⠀⠀⠓⡄⠀⠀⠀
⠀⠀⠀⠀⠈⠛⢿⣾⣳⣟⣾⣳⡽⣾⡽⣻⢾⣽⣻⢿⣷⣯⣿⣽⣻⣾⣿⣟⡷⣯⢷⢯⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠷⠾⡷⢾⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠉⢂
				              ]],
			},

			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup", padding = 1 },
				{ header = "Good Luck!" },
			},
		},
		indent = {
			enabled = false,
			indent = {
				char = "▏",
			},
			-- chunk = {
			-- 	enabled = true,
			-- },
			scope = { enabled = false, char = "▏" },
		},
		scroll = {
			enabled = false,
		},
		input = { enabled = false },
		notifier = {
			enabled = false,
			icons = {
				error = user.signs.error,
				warn = user.signs.warn,
				info = user.signs.info,
				debug = user.signs.debug,
				trace = user.signs.trace,
			},
			level = vim.log.levels.INFO,
			style = "minimal",
		},
		quickfile = { enabled = true },
		statuscolumn = {
			enabled = false,
			left = { "sign", "git" },
			right = { "mark", "fold" },
			folds = {
				open = false,
				git_hl = false,
			},
			refresh = 300,
		},
		scope = { enabled = false },
		words = { enabled = false, modes = { "n" } },

		zen = {
			toggles = {
				dim = false,
			},
		},

		dim = {
			animate = {
				enabled = false,
			},
		},

		picker = {
			enabled = true,
			icons = user.kinds,
			layouts = {
				vscode = {
					layout = {
						border = "rounded",
					},
				},
			},
		},

		lazygit = {
			configure = true,
		},

		terminal = {
			win = {
				wo = {
					winbar = "",
				},
			},
		},
		image = {
			enabled = false,
			doc = {
				enabled = false,
				inline = false,
				float = false,
				max_width = 30,
				max_height = 15,
			},
			convert = {
				notify = false,
			},
			math = {
				enabled = false,
			},
		},

		styles = {
			zen = {
				width = 180,
				backdrop = { transparent = false },
			},
		},
	},

    -- stylua: ignore
	keys = {
		{ "<leader>fr", function() Snacks.rename.rename_file() end, desc = "Rename File" },
		{ "<leader>bl", function() Snacks.git.blame_line() end, desc = "Git blame line", mode = { "n", "v" } },
		{ "<leader>gh", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
        { "<leader>to", function()
            require("snacks").picker.grep({
                search = [[TODO:|todo!\(.*\)]],
                live = false,
                supports_live = false,
                on_show = function()
                    vim.cmd.stopinsert()
                end,
            })
        end, { desc = "Grep TODOs", nargs = 0 }},
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        {"<leader>bo", function()
            Snacks.bufdelete.other()
        end,  desc = "Delete Other Buffers" },
        {
            "<leader>tt",
            function()
                Snacks.terminal(nil, {
                    win = {
                        keys = {
                            term_normal = {
                                "<esc>",
                                function()
                                    vim.cmd.stopinsert()
                                end,
                                mode = "t",
                                expr = true,
                                desc = "Single escape to normal mode",
                            },
                        },
                    },
                })
            end,
            desc = "Terminal",
	    },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
		{ "<leader>sh", function() Snacks.win({
            border = "rounded",
            zindex = 100,
            width = 0.6,
            height = 0.6,
            title = " Notification History ",
            title_pos = "center",
            ft = "vim",
            bo = { buflisted = false, bufhidden = "wipe", swapfile = false, modifiable = false, buftype = "nofile" },
            wo = { winhighlight = "NormalFloat:Normal", wrap = true },
            minimal = true,
            keys = { q = "close", ["<esc>"] = "close" },
            text = function ()
                return vim.split(vim.fn.execute("messages", "silent"), "\n")
            end
        }) end, desc = "Show Messages History" },
		{
			"<leader>no",
			function()
                ---@diagnostic disable-next-line: missing-fields
				Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown", file = vim.fn.stdpath("state") .. "/TODO.md" })
			end,
			desc = "Todo List",
		},
		{ "<leader>;", function() Snacks.picker.buffers({ on_show = function()
              vim.cmd.stopinsert()
            end }) end, desc = "Buffers" },
		{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config"), hidden = true }) end, desc = "Find Config File" },
		{ "<leader>ff", function() Snacks.picker.files({ hidden = true }) end, desc = "Find Files" },
		{ "<leader>of", function() Snacks.picker.recent() end, desc = "Recent" },
		{ "<leader>fs", function() Snacks.picker.grep({ hidden = true }) end, desc = "Grep" },
		{ "<leader>ph", function() Snacks.picker.highlights() end, desc = "Highlights" },
		{ "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
		{ "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>gl", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
        { "<leader>gs", function() Snacks.lazygit() end, desc = "Lazygit" },
		{
			"<leader>/",
			function()
				Snacks.picker.lines({
					layout = {
						preset = "default",
						preview = "preview",
					},
				})
			end,
			desc = "Grep Lines",
		},
		{ "<leader>u", function() Snacks.picker.undo({ on_show = function()
              vim.cmd.stopinsert()
            end,}) end, desc = "undo tree" },
		{ "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, desc = "Document Diagnostics" },
		{ "<leader>fD", function() Snacks.picker.diagnostics() end, desc = "Workspace Diagnostics" },
        { "<leader>fp", function() utils.pick_projects() end, desc = "Custom projects picker" },
        { "<leader>li", function () Snacks.picker.lsp_config() end, desc = "Lsp info" }
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("aqothy/snacks", { clear = true }),
			pattern = "VeryLazy",
			callback = function()
				vim.g.snacks_animate = false
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>cl")

				Snacks.toggle.dim():map("<leader>td")
				Snacks.toggle.zen():map("<leader>zz")
				Snacks.toggle.profiler():map("<leader>pp")

				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>sc")
			end,
		})
	end,
}
