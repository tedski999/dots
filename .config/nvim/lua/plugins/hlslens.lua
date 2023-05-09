return {
	"kevinhwang91/nvim-hlslens",
	opts = { nearest_float_when = "never" },
	keys = {
		"?", "/",
		{ "n", "<cmd>exe 'normal! '.v:count1.'n'<cr><cmd>lua require('hlslens').start()<cr>" },
		{ "N", "<cmd>exe 'normal! '.v:count1.'N'<cr><cmd>lua require('hlslens').start()<cr>" },
		{ "*", "*<cmd>lua require('hlslens').start()<cr>" },
		{ "#", "#<cmd>lua require('hlslens').start()<cr>" },
		{ "g*", "g*<cmd>lua require('hlslens').start()<cr>" },
		{ "g#", "g#<cmd>lua require('hlslens').start()<cr>" },
	}
}
