local ecma_snippets = {
    cl = "console.log(${0})",
    fn = "function ${1:name} (${2:arguments}) {\n\t${0}\n}",
    asf = "async function ${1:name} (${2:arguments}) {\n\t${0}\n}",
}

local snippets_by_filetype = {
    lua = {
        p = "print(${0})",
    },
    javascript = ecma_snippets,
    javascriptreact = ecma_snippets,
    typescript = ecma_snippets,
    typescriptreact = ecma_snippets,
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.tbl_keys(snippets_by_filetype),
    callback = function(ev)
        local snippets = snippets_by_filetype[vim.bo.filetype]
        if not snippets then
            return
        end

        vim.keymap.set({ "i", "s" }, "<C-;>", function()
            if vim.snippet.active() then
                vim.snippet.jump(1)
                return
            end

            local cursor = vim.api.nvim_win_get_cursor(0)
            local lnum, col = cursor[1] - 1, cursor[2]
            local line = vim.api.nvim_get_current_line()
            local before_cursor = line:sub(1, col)
            local trigger = before_cursor:match("(%w+)$")

            if trigger and snippets[trigger] then
                local start_char = col - #trigger
                vim.api.nvim_buf_set_text(ev.buf, lnum, start_char, lnum, col, { "" })
                vim.snippet.expand(snippets[trigger])
            end
        end, { buffer = ev.buf })
    end,
})
