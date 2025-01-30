-- Initialize pywal
local pywal = require('pywal')

-- Get pywal colors for custom highlights
local pywal_core = require('pywal.core')
local colors = pywal_core.get_colors()

-- Setup pywal
pywal.setup()

-- Set up custom highlights for line numbers and UI elements
local function custom_highlights()
    local highlights = {
        -- Line number highlights
        LineNr = { fg = colors.color7, bg = colors.color0 },
        CursorLineNr = { fg = colors.foreground, bg = colors.color0, bold = true },
        SignColumn = { bg = colors.color0 },
    }

    -- Apply highlights
    for group, conf in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, conf)
    end
end

-- Apply the custom highlights
custom_highlights()

-- Configure lualine with pywal theme
require('lualine').setup({
    options = {
        theme = 'pywal-nvim',
        component_separators = '|',
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = {
            { 'mode', separator = { left = '' }, right_padding = 2 },
        },
        lualine_b = { 'filename', 'branch' },
        lualine_c = { 'fileformat' },
        lualine_x = {},
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
            { 'location', separator = { right = '' }, left_padding = 2 },
        },
    },
    inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
    },
})

-- Configure bufferline with simplified styling
require('bufferline').setup({
    options = {
        mode = "buffers",
        separator_style = "none",
        show_buffer_close_icons = false,
        show_close_icon = false,
        color_icons = true,
        always_show_bufferline = true,
    },
    highlights = {
        fill = {
            bg = colors.color0,
        },
        background = {
            fg = colors.color7,
            bg = colors.color0,
        },
        buffer_selected = {
            fg = colors.foreground,
            bg = colors.color0,
            bold = true,
            italic = false,
        },
        buffer_visible = {
            fg = colors.color7,
            bg = colors.color0,
        },
        separator = {
            fg = colors.color0,
            bg = colors.color0,
        },
        modified = {
            fg = colors.color1,
            bg = colors.color0,
        },
        modified_selected = {
            fg = colors.color1,
            bg = colors.color0,
        },
    },
})