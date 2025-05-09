return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = function()
		local user = require("aqothy.config.user")

		return {
			bigfile = { enabled = true },

			indent = {
				enabled = false,
				indent = { enabled = true, char = "▏" },
				chunk = { enabled = false },
				scope = { enabled = true, char = "▎" },
				filter = function(buf)
					return vim.bo[buf].filetype ~= "snacks_picker_preview"
						and vim.bo[buf].filetype ~= "bigfile"
						and vim.g.snacks_indent ~= false
						and vim.b[buf].snacks_indent ~= false
						and vim.bo[buf].buftype == ""
				end,
			},

			input = { enabled = true },

			notifier = {
				enabled = true,
				icons = user.signs,
				level = vim.log.levels.INFO,
			},

			quickfile = { enabled = true },

			words = {
				enabled = true,
				modes = { "n" },
			},

			zen = {
				toggles = {
					dim = false,
				},
			},

			dim = {
				scope = {
					min_size = 1,
				},
				animate = {
					enabled = false,
				},
			},

			picker = {
				enabled = true,
				icons = {
					kinds = user.kinds,
				},
				ui_select = true,
				win = {
					input = {
						keys = {
							["<a-s>"] = { "flash", mode = { "n", "i" } },
							["<a-.>"] = { "toggle_hidden", mode = { "i", "n" } },
						},
					},
					list = {
						keys = {
							["<a-.>"] = { "toggle_hidden", mode = { "i", "n" } },
						},
					},
				},
				actions = {
					flash = function(picker)
						require("flash").jump({
							pattern = "^",
							label = { after = { 0, 0 } },
							search = {
								mode = "search",
								exclude = {
									function(win)
										return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
									end,
								},
							},
							action = function(match)
								local idx = picker.list:row2idx(match.pos[1])
								picker.list:_move(idx, true, true)
							end,
						})
					end,
				},
			},

			explorer = {
				replace_netrw = true,
			},

			image = {
				enabled = false,
				convert = {
					notify = false,
				},
			},

			scope = { enabled = true },

			styles = {
				notification = {
					wo = { wrap = true },
				},
				zen = {
					width = function()
						return math.floor(vim.o.columns * 0.7)
					end,
					backdrop = {
						transparent = false,
						blend = 95,
					},
				},
				terminal = {
					wo = {
						winbar = "",
					},
				},
			},
		}
	end,
    -- stylua: ignore
    keys = {
        { "<leader>bl", function() Snacks.git.blame_line() end, desc = "Git blame Line", mode = { "n", "v" } },
        { "<leader>gh", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>gY", function () Snacks.gitbrowse({ open = function (url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "v" },  },
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        {"<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
        {
            "<c-`>",
            function()
                Snacks.terminal(nil, {
                    win = {
                        keys = {
                            term_normal = "",
                        },
                    },
                })
            end,
            desc = "Toggle Terminal",
			mode = { "n", "t" },
		},
        { "<leader>nn", function() Snacks.notifier.hide() end, desc = "Hide Notifications" },
        {
            "<leader>sh",
            function() Snacks.win({
                zindex = 100,
                width = 0.6,
                height = 0.6,
                title = "Messages History ",
                title_pos = "center",
                ft = "vim",
                bo = { buflisted = false, bufhidden = "wipe", swapfile = false, modifiable = false, buftype = "nofile" },
                wo = { winhighlight = "NormalFloat:Normal", wrap = true },
                minimal = true,
                keys = { q = "close", ["<esc>"] = "close" },
                text = function ()
                    return vim.split(vim.fn.execute("messages", "silent"), "\n")
                end
            }) end,
            desc = "Show Messages History"
        },
        {
            "<leader>no",
            function()
                ---@diagnostic disable-next-line: missing-fields
                Snacks.scratch({
                    icon = " ",
                    name = "Todo",
                    ft = "markdown",
                    file = vim.fn.stdpath("state") .. "/TODO.md"
                })
            end,
            desc = "Todo List",
        },
        { "<leader>gs", function() Snacks.lazygit() end, desc = "Lazygit (cwd)" },
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log File" },
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>ee", function() Snacks.explorer({ hidden = true }) end, desc = "File Explorer" },
        {
            "<leader>to",
            function()
                Snacks.picker.grep({
                    search = [[TODO:|todo!\(.*\)]],
                    live = false,
                    supports_live = false,
                    on_show = function()
				        vim.cmd("stopinsert")
                    end,
                })
            end,
            desc = "Grep TODOs"
        },
        { "<leader>pr", function () Snacks.picker.resume() end, desc = "Resume Last Picker" },
        { "<leader>pa", function () Snacks.picker() end, desc = "All Pickers" },
        { "<leader>pi", function() Snacks.picker.icons() end, desc = "Pick icons" },
        { "<leader>pn", function() Snacks.picker.notifications() end, desc = "Pick Notifications" },
        {
            "<leader>,",
            function()
                Snacks.picker.buffers({
                    on_show = function()
				        vim.cmd("stopinsert")
                    end,
                })
            end,
            desc = "Buffers" },
        {
            "<leader>fc",
            function()
                Snacks.picker.files({
                    cwd = vim.fn.stdpath("config"),
                    hidden = true
                })
            end,
            desc = "Find Config File"
        },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
        { "<leader>ff", function() Snacks.picker.files({ hidden = true }) end, desc = "Find Files" },
        { "<leader>of", function() Snacks.picker.recent() end, desc = "Recent" },
        { "<leader>fs", function() Snacks.picker.grep({ hidden = true }) end, desc = "Grep" },
        { "<leader>ph", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
        { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep Lines" },
        { "<leader>u", function() Snacks.picker.undo() end, desc = "undo tree" },
        { "<leader>fp", function() require("aqothy.config.utils").pick_projects() end, desc = "Projects picker" },
        { "<leader>ps", function() Snacks.picker.spelling() end, desc = "Spelling" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command history" },
        { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    },
	config = function(_, opts)
		require("snacks").setup(opts)

		_G.dd = function(...)
			Snacks.debug.inspect(...)
		end
		_G.bt = function()
			Snacks.debug.backtrace()
		end
		vim.print = _G.dd

		-- Toggle
		Snacks.toggle.dim():map("<leader>sd")
		Snacks.toggle.diagnostics():map("<leader>td")
		Snacks.toggle.zen():map("<leader>zz")
		Snacks.toggle.profiler():map("<leader>pp")
		Snacks.toggle.indent():map("<leader>id")
		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>sp")
		Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
	end,
}
