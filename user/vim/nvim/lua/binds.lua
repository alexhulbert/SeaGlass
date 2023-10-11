local map = vim.api.nvim_set_keymap
local opts = { silent = true, noremap = true }

require("telescope").setup({
	extensions = {
		file_browser = {
			-- theme = "catppuccin",
            theme = "ivy",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
		},
	},
})
require("telescope").load_extension("file_browser")

map("n", "<C-n>", ":Telescope live_grep <CR>", opts)
map("n", "<C-f>", ":Telescope find_files <CR>", opts)
map("n", "<C-f>", ":Telescope find_files <CR>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<C-s>", ":HopWord <CR>", opts)
map("n", "<space>fb", ":Telescope file_browser", opts)
