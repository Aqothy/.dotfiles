local M = {}

local mini_icons = require("mini.icons")

function M.render()
    local relative_path = vim.fn.expand("%:.")
    local icon, icon_hl = mini_icons.get("file", relative_path)

    return " %#" .. icon_hl .. "#" .. icon .. " %#Winbar#" .. relative_path .. "%h%w%m%r"
end

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("aqothy/winbar", { clear = true }),
    desc = "Attach winbar",
    callback = function(args)
        if
            not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
            and vim.bo[args.buf].buftype == "" -- Normal buffer
            and vim.api.nvim_buf_get_name(args.buf) ~= "" -- Has a file name
        then
            vim.wo.winbar = "%{%v:lua.require'aqothy.config.winbar'.render()%}"
        end
    end,
})

return M
