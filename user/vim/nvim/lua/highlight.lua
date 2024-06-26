local tree = require("nvim-treesitter.configs")

tree.setup({
	highlight = {
		enable = true,
	},
	autotag = {
		enable = true,
	},
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = 3500,
	},
})
