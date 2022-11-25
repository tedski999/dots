
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
	# GPG agent
	gpg-connect-agent updatestartuptty /bye &>/dev/null
end

if status is-login
	set -gxa PATH "$HOME/.local/bin"
	# Default programs
	set -gx TERMINAL "alacritty"
	set -gx EDITOR "nvim"
	set -gx VISUAL "nvim"
	set -gx BROWSER "brave-browser"
	set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
	# Program settings
	set -gx SXHKD_SHELL "/bin/bash"
	set -gx _JAVA_AWT_WM_NONREPARENTING 1
	set -gx LIBVIRT_DEFAULT_URI "qemu:///system"
	set -gx DEBUGINFOD_URLS "https://debuginfod.archlinux.org"
	# GPG agent
	set -gx GPG_TTY (tty)
	set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
	gpgconf --launch gpg-agent
	# XDG Spec
	set -gx XDG_DATA_HOME "$HOME/.local/share"
	set -gx XDG_CONFIG_HOME "$HOME/.config"
	set -gx XDG_STATE_HOME "$HOME/.local/state"
	set -gx XDG_CACHE_HOME "$HOME/.cache"
	set -gx ANDROID_HOME "$XDG_DATA_HOME/android"
	set -gx HISTFILE "$XDG_STATE_HOME/bash/history"
	set -gx CALCHISTFILE "$XDG_CACHE_HOME/calc_history"
	set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
	set -gx CGDB_DIR "$XDG_CONFIG_HOME/cgdb"
	set -gx CUDA_CACHE_PATH "$XDG_CACHE_HOME/nv"
	set -gx DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"
	set -gx GOPATH "$HOME/.local/share/go"
	set -gx NODE_REPL_HISTORY "$XDG_DATA_HOME/node_repl_history"
	set -gx npm_config_userconfig "$HOME/.config/npm/npmrc"
	set -gx _JAVA_OPTIONS -Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
	set -gx PYTHONSTARTUP "$XDG_CONFIG_HOME/python/pythonrc"
	set -gx STACK_ROOT "$XDG_DATA_HOME/stack"
	set -gx WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"
	set -gx XAUTHORITY "$XDG_RUNTIME_DIR/Xauthority"
	alias wget "wget --hsts-file=$XDG_DATA_HOME/wget-hsts --output-file=/dev/null"
	# Start X server when logging in on tty1
	if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
		exec startx -- vt1 &>/dev/null
	end
end
