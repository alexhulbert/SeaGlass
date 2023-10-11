vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
vim.g.airline_theme = "catppuccin"
require("catppuccin").setup({
	transparent_background = false,
	integrations = {
		cmp = true,
		native_lsp = {
			enabled = true,
		},
		hop = true,
		telescope = true,
		treesitter = true,
		-- lsp_trouble = true,
		-- ts_rainbow = true,
	},
})
vim.cmd.colorscheme("catppuccin")
