return {
	"echasnovski/mini.icons",
	lazy = true,
	opts = {
		file = {
			[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
			["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			[".go-version"] = { glyph = "󰟓", hl = "MiniIconsBlue" },
			[".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			[".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
			[".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
			[".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
			["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
			["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
		},
		filetype = {
			dotenv = { glyph = "", hl = "MiniIconsYellow" },
			gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
			go = { glyph = "", hl = "MiniIconsAzure" },
		},
	},
	config = function(_, opts)
		local mi = require("mini.icons")
		mi.setup(opts)
		mi.mock_nvim_web_devicons()
	end,
}
