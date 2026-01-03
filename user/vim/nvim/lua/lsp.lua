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

for _, server in pairs(servers) do
    vim.lsp.config(server, {
        capabilities = capabilities,
    })
end

vim.lsp.enable(servers)

vim.g.rustaceanvim = {}