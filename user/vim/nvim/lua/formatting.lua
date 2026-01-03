local conform = require("conform")
local lint = require("lint")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		c = { "uncrustify" },
		cpp = { "uncrustify" },
		nix = { "alejandra" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		rust = { "rustfmt" },
	},
	formatters = {
		rustfmt = {
			prepend_args = { "--edition=2021" },
		},
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

lint.linters_by_ft = {
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	css = { "stylelint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
	callback = function()
		lint.try_lint()
	end,
})
