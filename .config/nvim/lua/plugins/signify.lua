-- VCS number column indicators
return {
	"mhinz/vim-signify",
	event = "VeryLazy",
	keys = {
		{ "<leader>gd", "<cmd>SignifyHunkDiff<cr>" },
		{ "<leader>gD", "<cmd>SignifyDiff!<cr>" },
		{ "<leader>gr", "<cmd>SignifyHunkUndo<cr>" },
	},
	config = function()
		vim.g.signify_number_highlight = 1
		vim.keymap.set("n", "[d", "<plug>(signify-prev-hunk)")
		vim.keymap.set("n", "]d", "<plug>(signify-next-hunk)")
		vim.keymap.set("n", "[D", "9999<plug>(signify-prev-hunk)")
		vim.keymap.set("n", "]D", "9999<plug>(signify-next-hunk)")
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
