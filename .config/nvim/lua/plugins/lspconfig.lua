return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = function()
		local lsp = require("lspconfig")
		require('lspconfig.ui.windows').default_options.border = vim.g.border_chars

		lsp.util.on_setup = lsp.util.add_hook_before(lsp.util.on_setup, function(cfg)
			cfg.capabilities = require("cmp_nvim_lsp").default_capabilities()
			cfg.on_attach = function(client, bufnr) end
		end)

		-- TODO(3, aesthetic): move lsp server settings to a table
		lsp.clangd.setup({})
		lsp.pylsp.setup({})
		lsp.rust_analyzer.setup({
			cmd = {'rustup', 'run', 'stable', 'rust-analyzer'},
			settings = { ['rust-analyzer'] = { checkOnSave = { overrideCommand = { 'cargo', 'clippy', '--workspace', '--message-format=json', '--all-targets', '--all-features' } } } }
		})

		-- local servers = { "clangd", "pylsp", "rust_analyzer" }
		-- for server in servers do
			-- lsp[server].setup(serveropts[server])
		-- end

		-- TODO(3, aesthetic): keybinding to reload all lsp servers

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
