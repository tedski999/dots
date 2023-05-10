return {
	"stevearc/oil.nvim",
	lazy = false,
	config = function()
		local oil = require("oil")
		vim.keymap.set("n", "-", oil.open)
		oil.setup({
			buf_options = { buflisted = false },
			win_options = { wrap = false, conceallevel = 0 },
			keymaps = {
				["<cr>"] = "actions.select",
				["<c-j>"] = "actions.select",
				["<c-s>"] = "actions.select_split",
				["<c-v>"] = "actions.select_vsplit",
				["<c-t>"] = "actions.select_tab",
				["<c-p>"] = "actions.preview",
				["<c-y>"] = "actions.copy_entry_path",
				["<esc>"] = "actions.close",
				["<c-c>"] = "actions.close",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "<cmd>Oil ~<cr>"
			},
			use_default_keymaps = false,
			view_options = { show_hidden = true },
			float = { border = vim.g.border_chars },
			preview = { border = vim.g.border_chars },
			progress = { border = "vim.g.border_chars" },
		})
	end
}
