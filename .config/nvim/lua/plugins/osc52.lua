-- Yank straight to system using OSC52
return {
	"ojroques/nvim-osc52",
	event = "TextYankPost",
	init = function()
		vim.api.nvim_create_autocmd("TextYankPost", { callback = function()
			if vim.v.event.operator == "y" and vim.v.event.regname == "" then
				require("osc52").copy_register("")
			end
		end })
	end,
	config = function()
		require("osc52").setup({ silent = true })
	end
}
