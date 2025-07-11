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

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
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
                        ["ao"] = "@conditional.outer",
                        ["io"] = "@conditional.inner",
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                        ["au"] = "@call.outer",
                        ["iu"] = "@call.inner",
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
        },
        config = function(_, opts)
            vim.treesitter.language.register("bash", { "kitty", "ghostty", "dotenv", "zsh" })

            require("nvim-treesitter.configs").setup(opts)

            Snacks.toggle.treesitter():map("<leader>ts")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "LazyFile",
        enabled = false,
        opts = function()
            local tsc = require("treesitter-context")
            Snacks.toggle({
                name = "Treesitter Context",
                get = tsc.enabled,
                set = function(state)
                    if state then
                        tsc.enable()
                    else
                        tsc.disable()
                    end
                end,
            }):map("<leader>tc")

            return {
                multiline_threshold = 3,
                max_lines = 3,
            }
        end,
    },
}
