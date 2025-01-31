return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	version = false,
	event = { "LazyFile", "VeryLazy" },
	lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
	cmd = { "TSUpdateSync", "TSUpdate", "TSInstall", "TSInfo" },
	init = function(plugin)
		require("lazy.core.loader").add_to_rtp(plugin)
		require("nvim-treesitter.query_predicates")
	end,
	config = function()
		require("nvim-treesitter.configs").setup({
			-- A list of parser names, or "all"
			ensure_installed = {
				"javascript",
				"typescript",
				"cpp",
				"python",
				"java",
				"go",
				"jsdoc",
				"bash",
				"css",
				"html",
				"tsx",
				"yaml",
				"json",
				"dockerfile",
				"c_sharp",
			},

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
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
				enable = true,
			},

			textobjects = {
				move = {
					enable = true,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
					},
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
					},
				},
			},

			highlight = {
				-- `false` will disable the whole extension
				enable = true,

				-- handled by snacks big file already
				-- disable = function(lang, buf)
				--     local max_filesize = 1024 * 1024
				--     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				--     if ok and stats and stats.size > max_filesize then
				--         return true
				--     end
				-- end,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
		})

		Snacks.toggle.treesitter():map("<leader>ts")
	end,
}
