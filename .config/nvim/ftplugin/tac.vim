function TaccIndentOverrides()
	let prev = getline(SkipTaccBlanksAndComments(v:lnum - 1))
	if prev =~# 'Tac::Namespace\s*{\s*$' | return 0 | endif
	return GetTaccIndent()
endfunction

setlocal indentexpr=TaccIndentOverrides()
