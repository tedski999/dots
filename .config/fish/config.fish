if status is-interactive
	# Git prompt
	set -g __fish_git_prompt_show_informative_status 1
	set -g __fish_git_prompt_hide_untrackedfiles 1
	set -g __fish_git_prompt_color_branch magenta
	set -g __fish_git_prompt_showupstream "informative"
	set -g __fish_git_prompt_char_upstream_ahead "↑"
	set -g __fish_git_prompt_char_upstream_behind "↓"
	set -g __fish_git_prompt_char_upstream_prefix ""
	set -g __fish_git_prompt_char_stagedstate "●"
	set -g __fish_git_prompt_char_dirtystate "○"
	set -g __fish_git_prompt_char_untrackedfiles "…"
	set -g __fish_git_prompt_char_conflictedstate "✖"
	set -g __fish_git_prompt_char_cleanstate "✔"
	set -g __fish_git_prompt_color_dirtystate blue
	set -g __fish_git_prompt_color_stagedstate green
	set -g __fish_git_prompt_color_invalidstate brred
	set -g __fish_git_prompt_color_untrackedfiles brred
	set -g __fish_git_prompt_color_cleanstate brgreen
	# GPG agent for SSH
	export SSH_AUTH_SOCK=(gpgconf --list-dirs agent-ssh-socket)
end
