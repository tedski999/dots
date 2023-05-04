return {
	"mhinz/vim-signify",
	event = "VeryLazy",
	keys = { { "<leader>gd", "<cmd>SignifyHunkDiff<cr>" } },
	config = function()
		local vcs_cmds = vim.g.signify_vcs_cmds or {}
		local vcs_cmds_diffmode = vim.g.signify_vcs_cmds_diffmode or {}

		local dotsrepo = "--git-dir=$HOME/.local/dots --work-tree=$HOME"
		vcs_cmds.git = "git diff --no-color --no-ext-diff -U0 -- %f || git "..dotsrepo.." diff --no-color --no-ext-diff -U0 -- %f"
		vcs_cmds_diffmode.git = "git show HEAD:./%f || git "..dotsrepo.." show HEAD:./%f"

		if vim.g.arista then
			vcs_cmds.perforce = "env P4DIFF= P4COLORS= a p4 diff -du 0 %f"
			vcs_cmds_diffmode.perforce = "a p4 print %f"
		end

		vim.g.signify_number_highlight = 1
		vim.g.signify_vcs_cmds = vcs_cmds
		vim.g.signify_vcs_cmds_diffmode = vcs_cmds_diffmode
		vim.cmd([[
			SignifyEnableAll
			" TODO(aesthetic): based on colorscheme
			highlight SignifySignAdd    guifg=#2aa889 guibg=#11151c
			highlight SignifySignChange guifg=#d26937 guibg=#11151c
			highlight SignifySignDelete guifg=#c23127 guibg=#11151c
		]])
	end
}
