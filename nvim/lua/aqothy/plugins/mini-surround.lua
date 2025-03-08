return {
	"echasnovski/mini.surround",
	keys = {
		{ "gz", mode = { "n", "v" } },
		{ "ds" },
		{ "cs" },
	},
	opts = {
		silent = true,
		mappings = {
			add = "gz",
			delete = "ds",
			find = "",
			find_left = "",
			highlight = "",
			replace = "cs",
			update_n_lines = "",
		},
		search_method = "cover_or_next",
		-- Custom surround for perserving attribute when changing tag
		custom_surroundings = {
			T = {
				input = { "<(%w+)[^<>]->.-</%1>", "^<()%w+().*</()%w+()>$" },
				output = function()
					local tag_name = MiniSurround.user_input("Tag name")
					if tag_name == nil then
						return nil
					end
					return { left = tag_name, right = tag_name }
				end,
			},
		},
	},
}
