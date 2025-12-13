-- npm install -g tree-sitter-cli
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = true,
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

            local ensure_installed = {
                -- Built into Neovim but need to install for other features like textobjects, etc
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
                "json",
                "swift",
                "python",
                "regex",
            }

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

            vim.treesitter.language.register("bash", { "kitty", "dotenv", "zsh" })

            TS.setup(opts)

            ts_utils.get_installed_parsers(true)

            local missing_parsers = vim.tbl_filter(function(lang)
                return not ts_utils.have(lang)
            end, ensure_installed or {})

            if #missing_parsers > 0 then
                TS.install(missing_parsers, { summary = true }):wait(30000)
            end

            ts_utils.get_installed_parsers(true)

            local filetypes = ts_utils.filetypes_from_langs(ensure_installed)

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

                    local function smap(key, query)
                        local outer = "@" .. query .. ".outer"
                        local inner = "@" .. query .. ".inner"
                        local desc = "Selection for " .. query .. " text objects"
                        map({ "x", "o" }, "a" .. key, function()
                            require("nvim-treesitter-textobjects.select").select_textobject(outer, "textobjects")
                        end, desc .. " (a)")
                        map({ "x", "o" }, "i" .. key, function()
                            require("nvim-treesitter-textobjects.select").select_textobject(inner, "textobjects")
                        end, desc .. " (i)")
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

                    smap("f", "function")
                    smap("c", "class")
                    smap("a", "parameter")
                    smap("L", "loop")
                    smap("C", "conditional")
                    smap("u", "call")
                    smap("/", "comment")
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = { "LazyFile", "VeryLazy" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
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
