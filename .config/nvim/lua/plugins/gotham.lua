return {
	"whatyouhide/vim-gotham",
	lazy = false,
	priority = 1000,
	config = function()
		vim.cmd([[
			colorscheme gotham

			highlight Folded guibg=NONE guifg=#888ca6

			highlight SpellBad guibg=NONE guifg=NONE gui=undercurl guisp=red
			highlight SpellCap guibg=NONE guifg=NONE gui=undercurl guisp=blue
			highlight SpellRare guibg=NONE guifg=NONE gui=undercurl guisp=purple
			highlight SpellLocal guibg=NONE guifg=NONE gui=undercurl guisp=yellow

			highlight LspReferenceText gui=bold
			highlight LspReferenceRead gui=bold
			highlight LspReferenceWrite gui=bold

			highlight ExtraWhitespace guibg=red guifg=red

			highlight link ColorColumn CursorColumn
		]])
	end
}
