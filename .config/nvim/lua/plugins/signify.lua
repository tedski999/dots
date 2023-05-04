return {
	"mhinz/vim-signify",
	event = "VeryLazy",
	keys = { { "<leader>gd", "<cmd>SignifyHunkDiff<cr>" } },
	config = function()
		local dotsrepo = "--git-dir=$HOME/.local/dots --work-tree=$HOME"
		vim.g.signify_vcs_cmds = { git = "git diff --no-color --no-ext-diff -U0 -- %f || git "..dotsrepo.." diff --no-color --no-ext-diff -U0 -- %f" }
		vim.g.signify_vcs_cmds_diffmode = { git = "git show HEAD:./%f || git "..dotsrepo.." show HEAD:./%f" }
		vim.g.signify_number_highlight = 1
		vim.cmd([[
			SignifyEnableAll
			" TODO: based on colorscheme
			highlight SignifySignAdd    guifg=#2aa889 guibg=#11151c
			highlight SignifySignChange guifg=#d26937 guibg=#11151c
			highlight SignifySignDelete guifg=#c23127 guibg=#11151c
		]])
	end
}
