local servers = {
    "pyright",
    "nil_ls",
    "rust_analyzer",
    "ts_ls",
    "gopls",
    "ccls",
    "bashls",
    "cmake",
    "html",
    "cssls",
}

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

for _, lsp in pairs(servers) do
    require("lspconfig")[lsp].setup({
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 200,
        },
    })
end

require("rust-tools").setup()