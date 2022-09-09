function dots --wraps="git --git-dir=$HOME/.local/dots/ --work-tree=$HOME" --description "git-versioned dotfiles"
	git --git-dir=$HOME/.local/dots/ --work-tree=$HOME $argv
end
