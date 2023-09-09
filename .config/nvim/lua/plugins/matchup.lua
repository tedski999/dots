-- A better matchit
return {
	"andymass/vim-matchup",
	lazy = false,
	keys = {
		-- { "yom", "<cmd>(g:matchup_matchparen_enabled == 1) ? 'NoMatchParen': 'DoMatchParen'<cr>" },
		{ "<leader>i", "<cmd>MatchupWhereAmI???<cr>" }
	},
	config = function()
		vim.g.matchup_matchparen_deferred = 1
		vim.g.matchup_matchparen_hi_surround_always = 1
		vim.g.matchup_matchparen_offscreen = { method = "popup", syntax_hl = 1 }
		vim.cmd("hi MatchParen guifg=none guibg=#333333 gui=bold")
	end
}