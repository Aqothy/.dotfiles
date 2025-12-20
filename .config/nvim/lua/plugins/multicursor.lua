local last_method = "match"
local last_dir = 1

local function mc(method, type_update, ...)
    local args = { ... }
    return function()
        if type_update then
            last_method = type_update
        end

        if args[1] and type(args[1]) == "number" then
            last_dir = args[1]
        end

        local obj = require("multicursor-nvim")
        obj[method](unpack(args))
    end
end

return {
    "jake-stewart/multicursor.nvim",
    -- stylua: ignore
    keys = {
        { "gl", mc("matchAddCursor", "match", 1), mode = { "n", "x" }, desc = "Add next match cursor" },
        { "gL", mc("matchAddCursor", "match", -1), mode = { "n", "x" }, desc = "Add previous match cursor" },
        { "m", mc("matchCursors", "match"), mode = "x", desc = "Cursor on matches in selection" },
        { "<down>", mc("lineAddCursor", "line", 1), mode = { "n", "x" }, desc = "Add line below cursor" },
        { "<up>", mc("lineAddCursor", "line", -1), mode = { "n", "x" }, desc = "Add line above cursor" },
        { "<leader>cl", mc("addCursorOperator", "line"), mode = { "n", "x" }, desc = "Add cursor for each line in range" },
        { "<leader>cs", mc("splitCursors", "match"), mode = "x", desc = "Split visual selections by regex" },
        { "<leader>k", mc("toggleCursor"), mode = { "n", "x" }, desc = "Toggle cursor" },
        { "gM", mc("operator", "match"), mode = { "n", "x" }, desc = "Cursor on all matches inside operator range" },
        { "<leader>ca", mc("alignCursors"), mode = "n", desc = "Align cursor columns" },
        { "<leader>cr", mc("restoreCursors"), mode = "n", desc = "Restore deleted cursors" },
        { "<leader>cd", mc("duplicateCursors"), mode = { "n", "x" }, desc = "Duplicate cursors" },
        { "I", mc("insertVisual"), mode = "x", desc = "Insert at start" },
        { "A", mc("appendVisual"), mode = "x", desc = "Append at end" },
    },
    config = function()
        local cursors = require("multicursor-nvim")

        cursors.setup()

        -- Keymap Layer: These only exist when multiple cursors are active
        cursors.addKeymapLayer(function(layerSet)
            layerSet({ "n", "x" }, "<left>", cursors.prevCursor)
            layerSet({ "n", "x" }, "<right>", cursors.nextCursor)

            layerSet({ "n", "x" }, "q", function()
                if last_method == "match" then
                    cursors.matchSkipCursor(last_dir)
                elseif last_method == "line" then
                    cursors.lineSkipCursor(last_dir)
                end
            end)

            layerSet({ "n", "x" }, "Q", function()
                if last_method == "match" then
                    cursors.matchSkipCursor(-last_dir)
                elseif last_method == "line" then
                    cursors.lineSkipCursor(-last_dir)
                end
            end)

            layerSet({ "n", "x" }, "n", function()
                if last_method == "match" then
                    cursors.matchAddCursor(last_dir)
                elseif last_method == "line" then
                    cursors.lineAddCursor(last_dir)
                end
            end)

            layerSet({ "n", "x" }, "N", function()
                if last_method == "match" then
                    cursors.matchAddCursor(-last_dir)
                elseif last_method == "line" then
                    cursors.lineAddCursor(-last_dir)
                end
            end)

            layerSet({ "n", "x" }, "<leader>cx", cursors.deleteCursor)

            layerSet("n", "<esc>", function()
                if not cursors.cursorsEnabled() then
                    cursors.enableCursors()
                else
                    cursors.clearCursors()
                end
            end)
        end)
    end,
}
