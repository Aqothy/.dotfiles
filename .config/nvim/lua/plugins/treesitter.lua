-- npm install -g tree-sitter-cli
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
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

                    if not ts_utils.have(ft, "textobjects") then
                        return
                    end

                    local function map(modes, lhs, rhs, desc)
                        vim.keymap.set(modes, lhs, rhs, { buffer = buf, silent = true, desc = desc })
                    end

                    local move = require("nvim-treesitter-textobjects.move")
                    local swap = require("nvim-treesitter-textobjects.swap")

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

                    map({ "n", "x", "o" }, "]a", function()
                        move.goto_next_start("@parameter.inner", "textobjects")
                    end, "Treesitter next parameter start")
                    map({ "n", "x", "o" }, "[a", function()
                        move.goto_previous_start("@parameter.inner", "textobjects")
                    end, "Treesitter prev parameter start")
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
