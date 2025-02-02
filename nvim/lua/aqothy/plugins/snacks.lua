local user = require("aqothy.config.user")
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
			indent = {
				enabled = false,
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
			enabled = true,
			icons = {
				error = user.signs.error,
				warn = user.signs.warn,
				info = user.signs.info,
				debug = user.signs.debug,
				trace = user.signs.trace,
			},
			level = vim.log.levels.INFO,
		},
		quickfile = { enabled = true },
		statuscolumn = {
			enabled = false,
			left = { "sign", "git" },
			right = { "mark", "fold" },
			folds = {
				open = true,
				git_hl = false,
			},
		},
		scope = { enabled = false },
		words = { enabled = false, modes = { "n" } },

		-- scratch = {
		--     win_by_ft = {
		--         javascript = {
		--             keys = {
		--                 ["source"] = {
		--                     "<cr>",
		--                     function(_)
		--                         vim.cmd("w !node")
		--                     end,
		--                     desc = "Source buffer",
		--                     mode = { "n", "x" },
		--                 },
		--             },
		--         },
		--         typescript = {
		--             keys = {
		--                 ["source"] = {
		--                     "<cr>",
		--                     function(_)
		--                         vim.cmd("w !node")
		--                     end,
		--                     desc = "Source buffer",
		--                     mode = { "n", "x" },
		--                 },
		--             },
		--         },
		--         python = {
		--             keys = {
		--                 ["source"] = {
		--                     "<cr>",
		--                     function(_)
		--                         vim.cmd("w !python3")
		--                     end,
		--                     desc = "Source buffer",
		--                     mode = { "n", "x" },
		--                 },
		--             },
		--         },
		--     },
		-- },

		zen = {
			toggles = {
				dim = false,
				git_signs = true,
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
		},

		lazygit = {
			configure = true,
		},

		styles = {
			-- your styles configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			zen = {
				width = 150,
				backdrop = { transparent = false },
				wo = {
					number = false,
					cursorcolumn = false,
					relativenumber = false,
					signcolumn = "no",
				},
			},
			notification = {
				wo = { wrap = true }, -- Wrap notifications
			},
			notification_history = {
				minimal = true,
				keys = { q = "close", ["<esc>"] = "close" },
			},
			terminal = {
				keys = {
					term_normal = {
						"<esc>",
						function(self)
							self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
							if self.esc_timer:is_active() then
								self.esc_timer:stop()
								vim.cmd("stopinsert")
							else
								self.esc_timer:start(500, 0, function() end) -- Increased debounce interval to 500ms
								return "<esc>"
							end
						end,
						mode = "t",
						expr = true,
						desc = "Double escape to normal mode",
					},
				},
			},
		},
	},
    -- stylua: ignore
	keys = {
		{ "<leader>nn", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
		{ "<leader>fr", function() Snacks.rename.rename_file() end, desc = "Rename File" },
		{ "<leader>bl", function() Snacks.git.blame_line() end, desc = "Git Browse", mode = { "n", "v" } },
		{ "<leader>gh", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
		{
			"<c-t>",
			function()
				Snacks.terminal(nil, { win = { border = "rounded", position = "float", height = 0.7, width = 0.7 } })
			end,
			desc = "Toggle Terminal",
		},
		{ "<M-w>", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader>sh", function() Snacks.notifier.show_history() end, desc = "Show Notifier History" },
		-- { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
		-- { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
		{
			"<leader>no",
			function()
				Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown", file = "~/.config/TODO.md" })
			end,
			desc = "Todo List",
		},
		{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config"), hidden = true}) end, desc = "Find Config File" },
		{ "<leader>ff", function() Snacks.picker.files({hidden = true}) end, desc = "Find Files" },
		{ "<leader>of", function() Snacks.picker.recent() end, desc = "Recent" },
		{ "<leader>fs", function() Snacks.picker.grep({hidden = true}) end, desc = "Grep" },
		{ "<leader>ph", function() Snacks.picker.highlights() end, desc = "Highlights" },
		{ "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
		{ "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
        { "<leader>gs", function() Snacks.lazygit() end, desc = "Lazygit" },
		{
			"<leader>f/",
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
		{ "<leader>u", function() Snacks.picker.undo() end, desc = "Buffer Lines" },
		{ "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, desc = "Document Diagnostics" },
		{ "<leader>fD", function() Snacks.picker.diagnostics() end, desc = "Workspace Diagnostics" },
        { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		vim.g.snacks_animate = false

		Snacks.toggle.dim():map("<leader>sd")
		Snacks.toggle.zen():map("<leader>zz")
		Snacks.toggle.animate():map("<leader>ta")
		Snacks.toggle.profiler():map("<leader>pp")

		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>sc")

		Snacks.toggle({
			name = "Copilot",
			get = function()
				return vim.g.copilot_enabled == 1
			end,
			set = function(state)
				vim.g.copilot_enabled = state
				if state then
					vim.cmd("Copilot enable")
				else
					vim.cmd("Copilot disable")
				end
			end,
		}):map("<leader>tc")

		-- Snacks.toggle({
		-- 	name = "Diffview",
		-- 	get = function()
		-- 		return require("diffview.lib").get_current_view()
		-- 	end,
		-- 	set = function(state)
		-- 		if state then
		-- 			require("diffview").open()
		-- 		else
		-- 			require("diffview").close()
		-- 		end
		-- 	end,
		-- }):map("<leader>gd")
	end,
}
