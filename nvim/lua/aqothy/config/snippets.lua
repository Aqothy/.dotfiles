local ecma_snippets = {
    l = "console.log(${0})",
    fn = "function ${1:name} (${2:arguments}) {\n\t${0}\n}",
    afn = "async function ${1:name} (${2:arguments}) {\n\t${0}\n}",
    rfc = [[
import React from 'react'

export default function ${1:${TM_FILENAME_BASE}}() {
  return (
    ${2}
  )
}
]],
    ue = [[
useEffect(() => {
  ${1:first}

  return () => {
    ${2:second}
  }
}, [${3:third}])
]],
    us = "const [${1:state}, set${2:State}] = useState(${3:initValue})",
}

local snippets_by_filetype = {
    lua = {
        l = "print(${0})",
    },
    go = {
        l = "fmt.Println($1)",
        ir = "if err != nil {\n\t$1\n}",
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

        vim.keymap.set("i", "<c-j>", function()
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
        end, { buffer = ev.buf, desc = "Expand snippets" })
    end,
})
