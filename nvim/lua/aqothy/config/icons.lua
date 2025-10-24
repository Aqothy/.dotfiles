local M = {}

M.kinds = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈔",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "",
}

M.dap = {
    Stopped = { "󰁕", "DiagnosticWarn" },
    Breakpoint = "",
    BreakpointCondition = "",
    BreakpointRejected = { "", "DiagnosticError" },
    LogPoint = ".>",
}

M.diagnostics = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = "",
}

M.git = {
    added = "",
    modified = "",
    removed = "",
}

return M
