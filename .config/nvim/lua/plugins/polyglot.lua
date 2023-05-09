return {
	"sheerun/vim-polyglot",
	event = "Syntax",
	config = function()
		vim.api.nvim_clear_autocmds({ event = { "BufNewFile", "BufRead" }, pattern = "*.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.tac,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript", group = "filetypedetect" })
		vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript", group = "filetypedetect", command = "setf python" })
	end
}
