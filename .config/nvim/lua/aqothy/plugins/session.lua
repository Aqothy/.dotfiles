return {
    "folke/persistence.nvim",
    lazy = false,
    opts = {
        branch = false,
        dir = vim.fn.stdpath("state") .. "/sessions/",
    },
    -- stylua: ignore
    keys = {
        { "<leader>rl", function() require("persistence").load() end, desc = "Restore Session" },
        { "<leader>ds", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
    config = function(_, opts)
        local allowed_dirs = {
            "~/Code/Personal/",
            "~/.config",
        }

        local cwd = vim.fn.expand(vim.fn.getcwd())
        local match_found = false

        for _, dir in ipairs(allowed_dirs) do
            local expanded_dir = vim.fn.expand(dir)
            if string.find(cwd, expanded_dir, 1, true) == 1 then
                match_found = true
                break
            end
        end

        if not match_found then
            return
        end

        local p = require("persistence")

        p.setup(opts)

        -- override persistence function to use dir based on starting cwd not ending
        p.current = function()
            local name = cwd:gsub("[\\/:]+", "%%")
            return opts.dir .. name .. ".vim"
        end

        local group = vim.api.nvim_create_augroup("aqothy/session", { clear = true })

        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceSavePre",
            group = group,
            callback = function()
                local ok, dv_lib = pcall(require, "diffview.lib")
                if ok and dv_lib and dv_lib.views then
                    for _, view in pairs(dv_lib.views) do
                        view:close()
                    end
                end
            end,
        })

        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            callback = function()
                if vim.fn.argc() == 0 then
                    require("persistence").load()
                end
            end,
            once = true,
            nested = true,
        })
    end,
}
