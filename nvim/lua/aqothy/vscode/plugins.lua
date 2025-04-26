return {
	{
		"kylechui/nvim-surround",
		keys = {
			{ "<C-g>s", mode = "i", desc = "Add Surround In Insert Mode" },
			{ "<C-g>S", mode = "i", desc = "Add Surround On New Lines In Insert Mode" },
			{ "gz", mode = { "n", "v" }, desc = "Surround Normal And Visual" },
			{ "gzz", mode = "n", desc = "Surround Current Line" },
			{ "gZ", mode = "n", desc = "Surround On New Lines" },
			{ "gZZ", mode = "n", desc = "Surround Current Line On New Lines" },
			{ "Z", mode = "v", desc = "Surround Visual Selection On New Lines" },
			{ "ds", mode = "n", desc = "Delete Surrounding" },
			{ "cs", mode = "n", desc = "Change Surrounding" },
			{ "cS", mode = "n", desc = "Change Surrounding On New Lines" },
		},
		opts = {
			keymaps = {
				insert = "<C-g>s",
				insert_line = "<C-g>S",
				normal = "gz",
				normal_cur = "gzz",
				normal_line = "gZ",
				normal_cur_line = "gZZ",
				visual = "gz",
				visual_line = "Z",
				delete = "ds",
				change = "cs",
				change_line = "cS",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = "VeryLazy",
		lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		init = function(plugin)
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		opts = {
			-- A list of parser names, or "all"
			ensure_installed = {
				-- Neovim
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",

				-- extras
				"javascript",
				"typescript",
				"cpp",
				"python",
				"java",
				"go",
				"bash",
				"css",
				"html",
				"tsx",
				"yaml",
				"json",
				"dockerfile",
				"regex",
			},

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<cr>",
					node_incremental = "<cr>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
			-- dont have cli installed locally so set to false also for some files I visit I dont need treesitter
			auto_install = false,

			indent = {
				enable = false,
			},

			textobjects = {
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]]"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[["] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
				},
			},

			highlight = { enable = false },
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{
		"folke/snacks.nvim",
		opts = {
			scope = { enabled = true },
		},
		-- stylua: ignore
		keys = {
			{ "<leader>gh", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
			---@diagnostic disable-next-line: missing-fields
			{ "<leader>gY", function () Snacks.gitbrowse({ open = function (url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "v" },  },
			{ "ai", mode = { "o", "x" }, desc = "Around indent" },
			{ "ii", mode = { "o", "x" }, desc = "In indent" },
			{ "]i", desc = "Next ident" },
			{ "[i", desc = "Prev ident" },
		},
	},
	{
		"Wansmer/treesj",
		keys = {
			{ "<leader>j", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
		},
		opts = { use_default_keymaps = false, max_join_length = 300 },
	},
	{
		"folke/flash.nvim",
		opts = {
			-- Disable enhanced f and t
			modes = {
				char = {
					enabled = false,
				},
			},
			label = {
				uppercase = false,
			},
		},
		keys = {
			{
				"<leader>;",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"<leader>S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
		},
	},
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				silent = true,
				search_method = "cover",
				custom_textobjects = {
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@conditional.outer", "@loop.outer" },
						i = { "@conditional.inner", "@loop.inner" },
					}),
					a = ai.gen_spec.treesitter({ i = "@parameter.inner", a = "@parameter.outer" }), -- params
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Camel case
						{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
						"^().*()$",
					},
					t = "", -- Disable custom tag textobjects, built in t is better
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
	},
}
