-- npm install -g tree-sitter-cli
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "LazyFile", "VeryLazy" },
        opts = {
            indent = { disable = { "swift" } },
            highlight = { disable = {} },
            folds = {},
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
                "swift",
                "python",
                "regex",
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

            local function apply_features(buf, ft)
                local lang = vim.treesitter.language.get_lang(ft)

                if not is_disabled(lang, "highlight", buf) then
                    pcall(vim.treesitter.start, buf, lang)
                end

                if not is_disabled(lang, "indent", buf) then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end

                if not is_disabled(lang, "folds", buf) then
                    local win = vim.fn.bufwinid(buf)
                    if win ~= -1 then
                        vim.wo[win][0].foldmethod = "expr"
                        vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    end
                end
            end

            TS.setup(opts)

            local ft_set = {}
            for _, lang in ipairs(opts.ensure_installed) do
                for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang) or {}) do
                    ft_set[ft] = true
                end
            end
            local fts = vim.tbl_keys(ft_set)
            vim.list_extend(fts, { "http" })

            vim.api.nvim_create_autocmd("FileType", {
                group = ts_group,
                pattern = fts,
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
                            if ft ~= "" and ft_set[ft] then
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
        branch = "main",
        opts = {
            move = { set_jumps = true },
            select = { lookahead = true },
        },
        keys = function()
            local function ts_bind(module, method, query)
                return function()
                    require(module)[method](query, "textobjects")
                end
            end

            local args_attr = { "@parameter.inner", "@attribute.inner" }

            return {
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
                    ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", { "@function.outer" }),
                    mode = { "n", "x", "o" },
                    desc = "Next Method",
                },
                {
                    "[m",
                    ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", { "@function.outer" }),
                    mode = { "n", "x", "o" },
                    desc = "Prev Method",
                },
                {
                    "]]",
                    ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", { "@class.outer" }),
                    mode = { "n", "x", "o" },
                    desc = "Next Class",
                },
                {
                    "[[",
                    ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", { "@class.outer" }),
                    mode = { "n", "x", "o" },
                    desc = "Prev Class",
                },
                {
                    "]a",
                    ts_bind("nvim-treesitter-textobjects.move", "goto_next_start", args_attr),
                    mode = { "n", "x", "o" },
                    desc = "Next Arg",
                },
                {
                    "[a",
                    ts_bind("nvim-treesitter-textobjects.move", "goto_previous_start", args_attr),
                    mode = { "n", "x", "o" },
                    desc = "Prev Arg",
                },
            }
        end,
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
