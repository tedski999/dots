-- Preconfigured native LSP configs
-- TODO: look into installing LSPs/DAPs/linters/formatters with mason
return {
	"neovim/nvim-lspconfig",
	cmd = { "LspStart", "LspStop", "LspInfo" },
	keys = { { "<leader>z", function() if next(vim.lsp.buf_get_clients()) == nil then vim.notify("Starting LSP...") vim.cmd("LspStart") else vim.notify("Stopping LSP...") vim.cmd("LspStop") end end } },
	config = function()
		local lsp = require("lspconfig")
		require("lspconfig.ui.windows").default_options.border = vim.g.border_chars

		lsp.clangd.setup({})
		lsp.pylsp.setup({})
		lsp.rust_analyzer.setup({
			cmd = { "rustup", "run", "stable", "rust-analyzer" },
			settings = { ["rust-analyzer"] = { checkOnSave = { overrideCommand = { "cargo", "clippy", "--workspace", "--message-format=json", "--all-targets", "--all-features" } } } }
		})

		if vim.g.arista then
			vim.api.nvim_create_user_command("Acdb", "belowright split | exec 'terminal echo \"Generating compile_commands.json...\" && cdbtool --tin '.<q-args>", { nargs = 1 })
			require("lspconfig.configs").tac = { default_config = {
				cmd = { "/usr/bin/artaclsp" },
				cmd_args = { "-I", "/bld/" },
				filetypes = { "tac" },
				root_dir = function() return "/src" end
			} }
			lsp.tac.setup({})
		end
	end
}
