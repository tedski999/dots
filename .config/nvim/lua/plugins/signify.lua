return {
	"mhinz/vim-signify",
	event = "VeryLazy",
	keys = { { "<leader>gd", "<cmd>SignifyHunkDiff<cr>" } },
	config = function()
		vim.g.signify_number_highlight = 1
		vim.cmd("SignifyEnableAll")
		if vim.g.arista then
			local vcs_cmds = vim.g.signify_vcs_cmds or {}
			local vcs_cmds_diffmode = vim.g.signify_vcs_cmds_diffmode or {}
			vcs_cmds.perforce = "env P4DIFF= P4COLORS= a p4 diff -du 0 %f"
			vcs_cmds_diffmode.perforce = "a p4 print %f"
			vim.g.signify_vcs_cmds = vcs_cmds
			vim.g.signify_vcs_cmds_diffmode = vcs_cmds_diffmode
		end
	end
}
