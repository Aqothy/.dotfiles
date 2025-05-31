local is_vscode = vim.g.vscode

require("aqothy.config." .. (is_vscode and "vscode" or "options"))

_G.LazyLoad = vim.fn.argc(-1) == 0

require("aqothy.config.lazy")

if not is_vscode then
    local function setup_config()
        require("aqothy.config.autocmds")
        require("vim._extui").enable({ msg = { pos = "box" } })
    end

    vim.filetype.add({
        filename = {
            [".env"] = "dotenv",
        },
        pattern = {
            [".*/kitty/.+%.conf"] = "kitty",
            [".*/ghostty/.+"] = "ghostty",
            ["%.env%.[%w_.-]+"] = "dotenv",
        },
    })

    -- Load autocmds immediately if starting nvim with file
    if not LazyLoad then
        setup_config()
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        group = vim.api.nvim_create_augroup("Lazyload_Config", { clear = true }),
        callback = function()
            if LazyLoad then
                setup_config()
            end
            require("aqothy.config.keymaps")
            require("aqothy.config.commands")
            require("aqothy.config.statusline")
            require("aqothy.config.utils").cowboy()
        end,
    })
end
