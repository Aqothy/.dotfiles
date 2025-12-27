-- npm install -g tree-sitter-cli
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "LazyFile", "VeryLazy" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        opts = {
            indent = {
                disable = { "swift", "python" },
            },
            highlight = {
                disable = {},
            },
            folds = {},
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter")
            local ts_utils = require("custom.utils")

            local function is_disabled(lang, feat, buf)
                local f = opts[feat] or {}
                if f.enabled == false then
                    return true
                end
                local disable = f.disable
                if type(disable) == "function" then
                    return disable(lang, buf)
                end
                return vim.tbl_contains(disable or {}, lang)
            end

            TS.setup(opts)

            ts_utils.get_installed_parsers(true)

            local missing_parsers = vim.tbl_filter(function(lang)
                return not ts_utils.have(lang)
            end, ts_utils.ensure_installed)

            if #missing_parsers > 0 then
                TS.install(missing_parsers, { summary = true }):wait()
                vim.cmd("restart")
            end

            local filetypes = ts_utils.get_ensured_parsers_fts()

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("aqothy/treesitter", { clear = true }),
                pattern = filetypes,
                callback = function(ev)
                    local ft = ev.match
                    local buf = ev.buf

                    if not ts_utils.have(ft) then
                        return
                    end

                    local lang = vim.treesitter.language.get_lang(ft)

                    if not is_disabled(lang, "highlight", buf) then
                        if ts_utils.have(ft, "highlights") then
                            pcall(vim.treesitter.start, buf, lang)
                        end
                    end

                    if not is_disabled(lang, "indent", buf) then
                        if ts_utils.have(ft, "indents") then
                            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end
                    end

                    if not is_disabled(lang, "folds", buf) then
                        if ts_utils.have(ft, "folds") then
                            local win = vim.api.nvim_get_current_win()
                            vim.wo[win][0].foldmethod = "expr"
                            vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        end
                    end

                    if not ts_utils.have(ft, "textobjects") then
                        return
                    end

                    local function map(modes, lhs, rhs, desc)
                        vim.keymap.set(modes, lhs, rhs, { buffer = buf, silent = true, desc = desc })
                    end

                    local move = require("nvim-treesitter-textobjects.move")
                    local swap = require("nvim-treesitter-textobjects.swap")

                    local function ts_bind(func, query)
                        return function()
                            func(query, "textobjects")
                        end
                    end

                    local args_attr = { "@parameter.inner", "@attribute.inner" }
                    map("n", "<leader>an", ts_bind(swap.swap_next, args_attr), "Swap Next Arg")
                    map("n", "<leader>ap", ts_bind(swap.swap_previous, args_attr), "Swap Prev Arg")

                    local nxo = { "n", "x", "o" }
                    local methods = { "@function.outer" }
                    local sections = { "@class.outer" }

                    map(nxo, "]m", ts_bind(move.goto_next_start, methods), "Next Method")
                    map(nxo, "[m", ts_bind(move.goto_previous_start, methods), "Prev Method")

                    map(nxo, "]]", ts_bind(move.goto_next_start, sections), "Next Class")
                    map(nxo, "[[", ts_bind(move.goto_previous_start, sections), "Prev Class")

                    map(nxo, "]a", ts_bind(move.goto_next_start, args_attr), "Next Arg")
                    map(nxo, "[a", ts_bind(move.goto_previous_start, args_attr), "Prev Arg")
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = true,
        opts = {
            move = {
                set_jumps = true,
            },
            select = {
                lookahead = true,
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "LazyFile",
        keys = {
            {
                "[g",
                function()
                    require("treesitter-context").go_to_context(vim.v.count1)
                end,
                desc = "Go to context",
            },
        },
        opts = {
            max_lines = 3,
        },
    },
}
