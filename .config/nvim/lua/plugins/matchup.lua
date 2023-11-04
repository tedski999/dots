-- A better matchit
return {
	"andymass/vim-matchup",
	lazy = false,
	keys = { { "<leader>i", "<cmd>MatchupWhereAmI???<cr>" } },
	config = function()
		vim.g.matchup_matchparen_deferred = 1
		vim.g.matchup_matchparen_hi_surround_always = 1
		vim.g.matchup_matchparen_offscreen = { method = "popup", syntax_hl = 1 }
		vim.cmd("hi MatchParen guifg=none guibg=#444444 gui=bold")
	end
}
