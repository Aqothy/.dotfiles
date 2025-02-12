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
			refresh = 300,
		},
		scope = { enabled = false },
		words = { enabled = false, modes = { "n" } },

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

		terminal = {
			win = {
				wo = {
					winbar = "",
				},
			},
		},
		image = {
			enabled = true,
		},

		styles = {
			-- your styles configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			zen = {
				width = 160,
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
						function()
							vim.cmd("stopinsert")
						end,
						mode = "t",
						expr = true,
						desc = "Single escape to normal mode",
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
		{
			"<c-j>",
			function()
                Snacks.terminal()
			end,
			desc = "Terminal",
		},
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        {"<leader>bo", function()
            Snacks.bufdelete.other()
        end,  desc = "Delete Other Buffers" },
		{ "<leader>sh", function() Snacks.picker.notifications() end, desc = "Show Notifier History" },
		{
			"<leader>no",
			function()
				Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown", file = "~/.config/TODO.md" })
			end,
			desc = "Todo List",
		},
		{ "<leader>;", function() Snacks.picker.buffers({ on_show = function()
              vim.cmd.stopinsert()
            end}) end, desc = "Buffers" },
		{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config"), hidden = true}) end, desc = "Find Config File" },
		{ "<leader>ff", function() Snacks.picker.files({ hidden = true }) end, desc = "Find Files" },
		{ "<leader>of", function() Snacks.picker.recent() end, desc = "Recent" },
		{ "<leader>fs", function() Snacks.picker.grep({hidden = true}) end, desc = "Grep" },
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
        { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
        { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
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

				Snacks.toggle.dim():map("<leader>sd")
				Snacks.toggle.zen():map("<leader>zz")
				Snacks.toggle.profiler():map("<leader>pp")

				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>sc")
			end,
		})
	end,
	config = function(_, opts)
		require("snacks").setup(opts)

		vim.g.snacks_animate = false

		local progress_augroup = vim.api.nvim_create_augroup("lsp_progress_notifier", { clear = true })

		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

		vim.api.nvim_create_autocmd("LspProgress", {
			pattern = { "begin", "end" },
			group = progress_augroup,
			---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
				if not client or type(value) ~= "table" then
					return
				end
				local msg = value.title or ""
				local is_done = ev.data.params.value.kind == "end"
				vim.notify(msg, "info", {
					id = client.name .. client.id,
					title = client.name,
                    opts = function(notif)
                        notif.icon = is_done and " "
							or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
						notif.timeout = is_done and 3000 or 0
					end,
				})
			end,
		})
	end,
}
