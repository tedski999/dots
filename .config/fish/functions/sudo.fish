function sudo --wraps=sudo --description "sudo wrapper to handle aliases"
	if functions -q -- $argv[1]
		set -l new_args (string join ' ' -- (string escape -- $argv))
		set argv fish -c "$new_args"
	end
	command sudo -E $argv
end
