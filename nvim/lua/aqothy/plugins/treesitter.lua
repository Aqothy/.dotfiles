return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "LazyFile",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
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
                "go",
                "bash",
                "tsx",
                "json5",
                "swift",
                "python",
            },

            incremental_selection = {
                enable = true,
                keymaps = {
                    node_incremental = "v",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },

            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- dont have cli installed locally so set to false also for some files I visit I dont need treesitter
            auto_install = false,

            indent = {
                enable = true,
                disable = { "swift" },
            },

            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",
                        ["au"] = "@call.outer",
                        ["iu"] = "@call.inner",
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                        ["ao"] = "@conditional.outer",
                        ["io"] = "@conditional.inner",
                    },
                },
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
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>an"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>ap"] = "@parameter.inner",
                    },
                },
            },

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
        config = function(_, opts)
            vim.treesitter.language.register("bash", { "kitty", "dotenv", "zsh" })

            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
