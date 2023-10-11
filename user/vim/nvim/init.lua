require("impatient")
require("options")
require("formatting")
require("lsp")
require("completion")
require("highlight")
require("binds")
require("theme")
require("Comment").setup()
require("bufferline").setup({
	highlights = require("catppuccin.groups.integrations.bufferline").get(),
	options = {
		separator_style = "slant",
	},
})
