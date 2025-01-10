function _G.project_search()
	require("fzf-lua").fzf_exec(
		"echo ~/.config; fd --type d --max-depth 1 --min-depth 1 . ~/.config ~/Code ~/Code/School ~/Code/Personal ~/Documents/documents-mac ~/Documents/documents-mac/school ~/Documents",
		{
			prompt = "Select a project > ",
			actions = {
				["default"] = function(selected)
					-- Use the chosen directory as the cwd for file search
					local project_dir = selected[1]
					vim.fn.chdir(project_dir)

					require("fzf-lua").files({ cwd = project_dir })
				end,
			},
		}
	)
end

return {
	"ibhagwan/fzf-lua",
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "Fzf-lua find files",
		},
		{
			"<leader>fs",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "Fzf-lua live grep",
		},
		{
			"<leader>gc",
			function()
				require("fzf-lua").git_commits()
			end,
			desc = "Fzf-lua git commits",
		},
		{
			"<leader>gb",
			function()
				require("fzf-lua").git_branches()
			end,
			desc = "Fzf-lua git branches",
		},
		-- Uncomment the following line if you want to enable git blame
		-- { "<leader>gB", function() require("fzf-lua").git_blame() end, desc = "Fzf-lua git blame" },
		{ "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Fzf-lua buffers" },
		{
			"<leader>of",
			function()
				require("fzf-lua").oldfiles()
			end,
			desc = "Fzf-lua old files",
		},
		{ "<C-F>", project_search, desc = "Find Project" }, -- Adjust `project_search` if needed
		{
			"<leader>fh",
			function()
				require("fzf-lua").help_tags()
			end,
			desc = "[F]ind [H]elp",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{ "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
	},
	config = function()
		local fzf = require("fzf-lua")

		-- local config = require("fzf-lua.config")
		local actions = require("fzf-lua.actions")

		-- config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open

		fzf.setup({
			fzf_colors = true,
			fzf_opts = {
				["--no-scrollbar"] = true,
			},
			defaults = {
				formatter = "path.dirname_first",
			},
			keymap = {
				builtin = {
					["<c-f>"] = "preview-page-down",
					["<c-b>"] = "preview-page-up",
				},
				fzf = {
					["ctrl-q"] = "select-all+accept",
					["ctrl-u"] = "half-page-up",
					["ctrl-d"] = "half-page-down",
					["ctrl-f"] = "preview-page-down",
					["ctrl-b"] = "preview-page-up",
				},
			},
			winopts = {
				width = 0.8,
				height = 0.8,
				row = 0.5,
				col = 0.5,
				preview = {
					scrollchars = { "┃", "" },
				},
			},
			files = {
				cwd_prompt = false,
				actions = {
					-- ["ctrl-i"] = { actions.toggle_ignore },
					["ctrl-h"] = { actions.toggle_hidden },
				},
			},
			grep = {
				actions = {
					-- ["ctrl-i"] = { actions.toggle_ignore },
					["ctrl-h"] = { actions.toggle_hidden },
				},
			},
			lsp = {
				jump_to_single_result = true,
				jump_to_single_result_action = actions.file_edit,
			},
			buffers = {
				keymap = { builtin = { ["<C-d>"] = false } },
				actions = { ["ctrl-x"] = false, ["ctrl-d"] = { actions.buf_del, actions.resume } },
			},
			oldfiles = {
				include_current_session = true,
			},
		})

		-- Register fzf-lua as vim.ui.select for a UI-select-like experience
		fzf.register_ui_select()
	end,
}
