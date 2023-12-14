return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
		"simrat39/rust-tools.nvim"
	},
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
		require("mason-lspconfig").setup_handlers({
			function(server)
				require("lspconfig")[server].setup({})
			end,
			["rust_analyzer"] = function()
				require("rust-tools").setup({
					tools = { inlay_hints = { only_current_line = true, parameter_hints_prefix = "" } },
					server = {}, -- TODO: no snippet capabilities
				})
			end,
			["lua_ls"] = function()
				require("lspconfig")["lua_ls"].setup({ settings = { Lua = { diagnostics = { globals = { 'vim' } } } } })
			end
		})

		-- TODO: dap config
		--[[ local dap = require("dap")
		vim.keymap.set("n", "<leader>yt", "<cmd>DapToggleBreakpoint<cr>")
		vim.keymap.set("n", "<leader>ys", "<cmd>DapToggleStepInto<cr>")
		vim.keymap.set("n", "<leader>yS", "<cmd>DapToggleStepOver<cr>")
		vim.keymap.set('n', '<leader>yk', function() dap.up() end)
		vim.keymap.set('n', '<leader>yj', function() dap.down() end)
		vim.keymap.set('n', '<leader>yr', function() dap.repl.toggle({}, "vsplit") end)

		vim.fn.sign_define('DapBreakpoint', {text = '🟥', texthl = '', linehl = '', numhl = ''})
		vim.fn.sign_define('DapBreakpointRejected', {text = '🟦', texthl = '', linehl = '', numhl = ''})
		vim.fn.sign_define('DapStopped', {text = '⭐️', texthl = '', linehl = '', numhl = ''})

		dap.adapters.lldb = {
			type = "executable",
			command = "/usr/bin/lldb",
			name = "lldb",
		}

		dap.configurations.rust = {
			{
				name = "hello-world",
				type = "lldb",
				request = "launch",
				program = function() return vim.fn.getcwd() .. "/target/debug/mctrl_server" end,
				cwd = "${workspaceFolder}",
				stopOnEntry = true,
			},
		} ]]


	end
}
