function la --wraps=exa --description "alias la exa"
	exa -lahs=name --git --group-directories-first $argv
end
