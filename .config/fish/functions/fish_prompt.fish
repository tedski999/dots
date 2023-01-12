function fish_prompt --description "Write out the left-hand prompt"
	set last_status $status

	echo ""

	set_color red
	echo -n $USER@(prompt_hostname)" "

	set_color blue
	echo -n (fish_prompt_pwd_dir_length=0 prompt_pwd)" "

	if test $last_status != 0
		set_color brred
		echo -n $last_status" "
	end

	echo ""

	set_color normal
	echo -n "> "
end
