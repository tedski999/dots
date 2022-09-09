function ls --wraps=exa --description "alias ls exa"
	exa -hs=name --group-directories-first $argv
end
