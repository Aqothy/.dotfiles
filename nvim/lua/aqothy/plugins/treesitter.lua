return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        event = "VeryLazy",
        opts = {
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
                "haskell",
            },

            indent = {
                disable = { "swift", "python" },
            },

            highlight = {
                disable = {},
            },
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter")
            local ts_utils = require("aqothy.config.utils")

            local function is_disabled(disable, lang, buf)
                if type(disable) == "function" then
                    return disable(lang, buf)
                end
                return vim.tbl_contains(disable or {}, lang)
            end

            vim.treesitter.language.register("bash", { "kitty", "dotenv", "zsh" })

            TS.setup(opts)

            ts_utils.get_installed_parsers(true)

            local missing_parsers = vim.tbl_filter(function(lang)
                return not ts_utils.have(lang)
            end, opts.ensure_installed or {})

            if #missing_parsers > 0 then
                TS.install(missing_parsers, { summary = true }):await(function()
                    ts_utils.get_installed_parsers(true)
                end)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("aqothy/treesitter", { clear = true }),
                callback = function(ev)
                    if not ts_utils.have(ev.match) then
                        return
                    end

                    local lang = vim.treesitter.language.get_lang(ev.match)

                    if not is_disabled(opts.highlight.disable, lang, ev.buf) then
                        pcall(vim.treesitter.start, ev.buf, lang)
                    end

                    if not is_disabled(opts.indent.disable, lang, ev.buf) then
                        if ts_utils.have(ev.match, "indents") then
                            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = "LazyFile",
        opts = {
            select = { lookahead = true },
            move = {
                set_jumps = true,
            },
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter-textobjects")
            TS.setup(opts)

            local ts_utils = require("aqothy.config.utils")

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("aqothy/treesitter_textobjects", { clear = true }),
                callback = function(ev)
                    if not ts_utils.have(ev.match, "textobjects") then
                        return
                    end

                    local select = require("nvim-treesitter-textobjects.select")
                    local move = require("nvim-treesitter-textobjects.move")
                    local swap = require("nvim-treesitter-textobjects.swap")

                    local function map(modes, lhs, rhs, desc)
                        vim.keymap.set(modes, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
                    end

                    map({ "x", "o" }, "af", function()
                        select.select_textobject("@function.outer", "textobjects")
                    end, "Treesitter select function outer")
                    map({ "x", "o" }, "if", function()
                        select.select_textobject("@function.inner", "textobjects")
                    end, "Treesitter select function inner")
                    map({ "x", "o" }, "ac", function()
                        select.select_textobject("@class.outer", "textobjects")
                    end, "Treesitter select class outer")
                    map({ "x", "o" }, "ic", function()
                        select.select_textobject("@class.inner", "textobjects")
                    end, "Treesitter select class inner")
                    map({ "x", "o" }, "aa", function()
                        select.select_textobject("@parameter.outer", "textobjects")
                    end, "Treesitter select parameter outer")
                    map({ "x", "o" }, "ia", function()
                        select.select_textobject("@parameter.inner", "textobjects")
                    end, "Treesitter select parameter inner")
                    map({ "x", "o" }, "au", function()
                        select.select_textobject("@call.outer", "textobjects")
                    end, "Treesitter select call outer")
                    map({ "x", "o" }, "iu", function()
                        select.select_textobject("@call.inner", "textobjects")
                    end, "Treesitter select call inner")
                    map({ "x", "o" }, "al", function()
                        select.select_textobject("@loop.outer", "textobjects")
                    end, "Treesitter select loop outer")
                    map({ "x", "o" }, "il", function()
                        select.select_textobject("@loop.inner", "textobjects")
                    end, "Treesitter select loop inner")
                    map({ "x", "o" }, "ao", function()
                        select.select_textobject("@conditional.outer", "textobjects")
                    end, "Treesitter select conditional outer")
                    map({ "x", "o" }, "io", function()
                        select.select_textobject("@conditional.inner", "textobjects")
                    end, "Treesitter select conditional inner")
                    map({ "x", "o" }, "a/", function()
                        select.select_textobject("@comment.outer", "textobjects")
                    end, "Treesitter select comment outer")

                    map("n", "<leader>an", function()
                        swap.swap_next("@parameter.inner", "textobjects")
                    end, "Treesitter swap next parameter")
                    map("n", "<leader>ap", function()
                        swap.swap_previous("@parameter.inner", "textobjects")
                    end, "Treesitter swap prev parameter")

                    map({ "n", "x", "o" }, "]m", function()
                        move.goto_next_start({ "@function.outer", "@class.outer" }, "textobjects")
                    end, "Treesitter next function or class start")
                    map({ "n", "x", "o" }, "[m", function()
                        move.goto_previous_start({ "@function.outer", "@class.outer" }, "textobjects")
                    end, "Treesitter prev function or class start")
                end,
            })
        end,
    },
}
