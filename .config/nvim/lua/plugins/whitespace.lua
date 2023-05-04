return {
	"ntpeters/vim-better-whitespace",
	lazy = false,
	init = function()
		vim.g.show_spaces_that_precede_tabs = 1
		-- vim.g.better_whitespace_filetypes_blacklist:append({})
		vim.api.nvim_create_autocmd("TermEnter", { callback = function() vim.cmd("DisableWhitespace") end })
	end
}
