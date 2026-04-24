-- pnpm add -g tree-sitter-cli
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "VeryLazy", "LazyFile" },
        cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
        init = function()
            vim.treesitter.language.register("bash", { "kitty", "zsh" })
        end,
        opts = {
            indent = { disable = { "swift" } },
            highlight = { disable = {} },
            folds = { disable = {} },
            ensure_installed = {
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
                "json5",
                "swift",
                "python",
                "regex",
                "html",
                "rust",
                "yaml",
                "diff",
                "http",
                "sql",
                "printf",
            },
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter")
            local ts_group = vim.api.nvim_create_augroup("aqothy/treesitter", { clear = true })

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

            local function has_query(lang, query)
                local ok, res = pcall(vim.treesitter.query.get, lang, query)
                return ok and res ~= nil
            end

            local function apply_features(buf, ft)
                local lang = vim.treesitter.language.get_lang(ft)
                local has_parser = lang and vim.treesitter.language.add(lang)

                if has_parser and not is_disabled(lang, "highlight", buf) and has_query(lang, "highlights") then
                    pcall(vim.treesitter.start, buf, lang)
                end

                if has_parser and not is_disabled(lang, "indent", buf) and has_query(lang, "indents") then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end

                if has_parser and not is_disabled(lang, "folds", buf) and has_query(lang, "folds") then
                    require("custom.folds").set_provider(buf, "treesitter")
                end
            end

            TS.setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                group = ts_group,
                callback = function(ev)
                    apply_features(ev.buf, ev.match)
                end,
            })

            local parsers = {}
            for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
                parsers[lang] = true
            end
            local missing_parsers = vim.tbl_filter(function(lang)
                return not parsers[lang]
            end, opts.ensure_installed)

            if #missing_parsers > 0 then
                TS.install(missing_parsers, { summary = true }):await(function(err)
                    vim.schedule(function()
                        if err then
                            vim.notify("Treesitter install failed: " .. err, vim.log.levels.ERROR)
                            return
                        end
                        -- Re-apply features to all buffers after new parsers are installed
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                            local ft = vim.bo[buf].filetype
                            if ft ~= "" then
                                apply_features(buf, ft)
                            end
                        end
                    end)
                end)
            end
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        opts = {
            move = { set_jumps = true },
            select = { lookahead = true },
        },
        keys = function()
            local rep = require("custom.repeat")

            local function ts_bind(module, method, query)
                return function()
                    require(module)[method](query, "textobjects")
                end
            end

            local args_attr = { "@parameter.inner", "@attribute.inner" }
            local next_method, prev_method = rep.pair(
                ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", { "@function.outer" }),
                ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", { "@function.outer" })
            )
            local next_class, prev_class = rep.pair(
                ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", { "@class.outer" }),
                ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", { "@class.outer" })
            )
            local next_arg, prev_arg = rep.pair(
                ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", args_attr),
                ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", args_attr)
            )
            local next_comment, prev_comment = rep.pair(
                ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", { "@comment.outer" }),
                ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", { "@comment.outer" })
            )

            return {
                {
                    "f",
                    rep.builtin_f_expr,
                    mode = { "n", "x", "o" },
                    expr = true,
                },
                {
                    "F",
                    rep.builtin_F_expr,
                    mode = { "n", "x", "o" },
                    expr = true,
                },
                {
                    "t",
                    rep.builtin_t_expr,
                    mode = { "n", "x", "o" },
                    expr = true,
                },
                {
                    "T",
                    rep.builtin_T_expr,
                    mode = { "n", "x", "o" },
                    expr = true,
                },
                {
                    ";",
                    rep.semicolon,
                    mode = { "n", "x", "o" },
                    desc = "Repeat next move",
                },
                {
                    ",",
                    rep.comma,
                    mode = { "n", "x", "o" },
                    desc = "Repeat previous move",
                },
                {
                    "<localleader>a",
                    ts_bind("nvim-treesitter-textobjects.swap", "swap_next", args_attr),
                    desc = "Swap Next Arg",
                },
                {
                    "<localleader>A",
                    ts_bind("nvim-treesitter-textobjects.swap", "swap_previous", args_attr),
                    desc = "Swap Prev Arg",
                },
                {
                    "]m",
                    next_method,
                    mode = { "n", "x", "o" },
                    desc = "Next Method",
                },
                {
                    "[m",
                    prev_method,
                    mode = { "n", "x", "o" },
                    desc = "Prev Method",
                },
                {
                    "]]",
                    next_class,
                    mode = { "n", "x", "o" },
                    desc = "Next Class",
                },
                {
                    "[[",
                    prev_class,
                    mode = { "n", "x", "o" },
                    desc = "Prev Class",
                },
                {
                    "]a",
                    next_arg,
                    mode = { "n", "x", "o" },
                    desc = "Next Arg",
                },
                {
                    "[a",
                    prev_arg,
                    mode = { "n", "x", "o" },
                    desc = "Prev Arg",
                },
                {
                    "]/",
                    next_comment,
                    mode = { "n", "x", "o" },
                    desc = "Next Comment",
                },
                {
                    "[/",
                    prev_comment,
                    mode = { "n", "x", "o" },
                    desc = "Prev Comment",
                },
            }
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "LazyFile",
        keys = {
            {
                "[C",
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
