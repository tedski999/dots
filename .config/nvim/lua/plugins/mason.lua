return {
	"williamboman/mason.nvim",
	dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig", "simrat39/rust-tools.nvim" },
	lazy = false,
	keys = { { "<leader>z", function() if next(vim.lsp.buf_get_clients()) == nil then vim.notify("Starting LSP...") vim.cmd("LspStart") else vim.notify("Stopping LSP...") vim.cmd("LspStop") end end } },
	config = function()
		require("lspconfig.ui.windows").default_options.border = vim.g.border_chars

		require("mason").setup({
			ui = {
				border = vim.g.border_chars,
				icons = { package_installed = "o", package_pending = "?", package_uninstalled = "x" }
			}
		})

		require("mason-lspconfig").setup({})

		require("mason-lspconfig").setup_handlers {
			function (server)
				require("lspconfig")[server].setup({})
			end,
			["rust_analyzer"] = function()
				require("rust-tools").setup({})
			end
		}
	end
}
