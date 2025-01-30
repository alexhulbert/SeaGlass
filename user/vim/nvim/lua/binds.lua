local map = vim.api.nvim_set_keymap
local opts = { silent = true, noremap = true }

require("telescope").setup({
    extensions = {
        file_browser = {
            theme = "ivy",
            hijack_netrw = true,
        },
    },
})
require("telescope").load_extension("file_browser")

map("n", "<C-n>", "<cmd>Telescope live_grep<CR>", opts)
map("n", "<C-f>", "<cmd>Telescope find_files<CR>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<C-s>", "<cmd>HopWord<CR>", opts)
map("n", "<space>fb", "<cmd>Telescope file_browser<CR>", opts)

local commands = {
    'command! -bang Wq w<bang>q',
    'command! -bang WQ w<bang>q',
    'command! -bang W w<bang>',
    'command! -bang Q q<bang>',
    'command! Ws w !sudo tee %',
    'command! WS wa',
}

for _, cmd in ipairs(commands) do
    vim.cmd(cmd)
end