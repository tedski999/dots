-- Language packs (while I wait patiently for Treesitter)
return {
	"sheerun/vim-polyglot",
	lazy = false,
	init = function()
		-- Fixes Arista indentation
		if vim.g.arista then
			vim.g.polyglot_disabled = { "autoindent" }
		end
	end,
	config = function()
		-- Fixes TAC filetype detection
		if vim.g.arista then
			vim.api.nvim_clear_autocmds({ event = { "BufNewFile", "BufRead" }, pattern = "*.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.tac,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript", group = "filetypedetect" })
			vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript", group = "filetypedetect", command = "setf python" })
		end
	end
}
