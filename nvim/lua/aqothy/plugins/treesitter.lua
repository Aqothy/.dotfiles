return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "VeryLazy",
        lazy = vim.fn.argc(-1) == 0,
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
                "python",
                "java",
                "go",
                "bash",
                "css",
                "html",
                "tsx",
                "yaml",
                "json5",
                "dockerfile",
                "regex",
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

            indent = { enable = true },

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
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
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
