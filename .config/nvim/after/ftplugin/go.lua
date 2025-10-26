local fn = vim.fn

local function goModTag(operation)
    if fn.executable("gomodifytags") == 0 then
        vim.notify("gomodifytags not found", vim.log.levels.ERROR)
    end

    if vim.bo.modified then
        vim.notify("File is modified, please save before adding JSON tags", vim.log.levels.WARN)
        return
    end

    local filename = fn.expand("%:p")

    vim.ui.input({
        prompt = "Enter struct name (empty for all structs): ",
    }, function(struct_name)
        -- User canceled the input
        if struct_name == nil then
            return
        end

        local cmd = "gomodifytags -file " .. fn.shellescape(filename)

        if struct_name ~= "" then
            cmd = cmd .. " -struct " .. fn.shellescape(struct_name)
        else
            cmd = cmd .. " -all"
        end

        cmd = cmd .. " -" .. operation .. "-tags json -transform camelcase -w --quiet"

        local output = fn.system(cmd)

        if vim.v.shell_error ~= 0 then
            vim.notify("Failed to add JSON tags: " .. output, vim.log.levels.ERROR)
            return
        end

        vim.cmd("checktime")
    end)
end

vim.keymap.set("n", "<leader>aj", function()
    goModTag("add")
end, { desc = "Add json tags to struct", buffer = true })

vim.keymap.set("n", "<leader>rj", function()
    goModTag("remove")
end, { desc = "Remove json tags from struct", buffer = true })
