local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- Create an autogroup for autosave
--local autosave_augroup = vim.api.nvim_create_augroup("Autosave", { clear = true })
--
--vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--	group = autosave_augroup,
--	pattern = "*",
--	callback = function()
--		vim.cmd("silent! write") -- Automatically save the current buffer
--	end,
--})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight on yank
autocmd("TextYankPost", {
    group = augroup("HighlightYank"),
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

-- resize splits if window got resized
autocmd("VimResized", {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- wrap and check for spell in text filetypes
autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "tex", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
    group = augroup("json_conceal"),
    pattern = { "json", "jsonc", "json5" },
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})
