function wget --wraps=wgetvim --description "alias for wget"
	wget --hsts-file=$XDG_DATA_HOME/wget-hsts --output-file=/dev/null &argv
end
