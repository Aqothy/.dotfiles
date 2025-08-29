require("aqothy.config.options")
vim.filetype.add({
    filename = {
        [".env"] = "dotenv",
    },
    pattern = {
        [".*/kitty/.+%.conf"] = "kitty",
        ["%.env%.[%w_.-]+"] = "dotenv",
    },
})

require("aqothy.config")

local lazyLoad = vim.fn.argc(-1) == 0

-- Load autocmds immediately if starting nvim with file
if not lazyLoad then
    require("aqothy.config.autocmds")
end

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    group = vim.api.nvim_create_augroup("aqothy/lazyload_config", { clear = true }),
    callback = function()
        if lazyLoad then
            require("aqothy.config.autocmds")
        end
        require("aqothy.config.keymaps")
        require("aqothy.config.commands")
    end,
})
require("vim._extui").enable({})
