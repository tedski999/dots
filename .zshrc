# Environment variables
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="less --long-prompt --ignore-case"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export CALCHISTFILE="$XDG_CACHE_HOME/calc_history"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export FZF_DEFAULT_COMMAND="rg --files --follow --no-ignore-vcs --hidden -g '!{**/node_modules/*,**/.git/*}'"
export GOPATH="$XDG_DATA_HOME/go"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export ZSH_DATA="$XDG_DATA_HOME/zsh"
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'

# GPG+SSH
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpgconf --launch gpg-agent

# History
HISTFILE="$ZSH_DATA/history"
HISTSIZE="10000"
SAVEHIST="10000"

# Better time format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# Aliases
alias sudo="sudo --preserve-env env PATH=$PATH "
alias dots="git --git-dir=$HOME/.local/dots --work-tree=$HOME"
alias v="nvim"
alias r="ranger"
alias fd="fdfind"
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias ip="ip --color=auto"
alias ls="exa -hs=name --group-directories-first"
alias la="ls -la"
alias d="dirs -v"
for i ({1..9}) alias "$i"="cd +$i"
for i ({3..9}) alias "${(l:i::.:)}"="${(l:i-1::.:)};.."
if [ "${HOST%%.*}" = "us260" ]; then
	alias s="a4c shell"
else
	alias s="mosh --predict=always --predict-overwrite --experimental-remote-ip=local us260 -- tmux new"
	alias S='mut=$(M) && s -c a ssh $mut'
fi

# Shorthand for un/mounting MUTs using SSHFS
function m {
	fusermount -uq /src
	M >/dev/null 2>&1 && { >&2 echo "Unable to unmount"; return 1 }
	[ -z "$1" ] && return 0
	sshfs "$1:/src" "/src" \
		-o reconnect -o kernel_cache -o idmap=user -o compression=yes -o ServerAliveInterval=15 -o max_conns=8 \
		-o cache_timeout=600 -o cache_stat_timeout=600 -o cache_dir_timeout=600 -o cache_link_timeout=600 \
		-o dcache_timeout=600 -o dcache_stat_timeout=600 -o dcache_dir_timeout=600 -o dcache_link_timeout=600 \
		-o entry_timeout=600 -o negative_timeout=600 -o attr_timeout=600
}

# Print current mounted MUT hostname
function M {
	mut="$(findmnt -no SOURCE /src | cut -d: -f1)"
	[ -z "$mut" ] && { >&2 echo "No MUT mounted"; return 1 }
	echo "$mut"
}

# Cheatsheets
function cht {
	curl cht.sh/$1
}

# Options
setopt autocd interactive_comments notify
setopt auto_pushd pushd_ignore_dups pushd_silent
setopt hist_ignore_all_dups hist_reduce_blanks share_history extended_history
setopt numericglobsort prompt_subst
setopt glob_complete complete_in_word

# Colours
eval "$(dircolors -b)"

# Vi keybindings
bindkey -v
export KEYTIMEOUT=1

# External editor
autoload edit-command-line
zle -N edit-command-line
bindkey "^V" edit-command-line
bindkey -M vicmd "^V" edit-command-line

# Better keybindings
bindkey "^W" backward-kill-word
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
for km in vicmd viins; bindkey -M $km "^[[3~" delete-char

# Block/beam cursor and dynamic prompt
PS1=$'\n%F{red}%n@%m%f %F{blue}%~%f %F{red}%(?..%?)%f\n>%f '
function zle-line-init zle-keymap-select {
	echo -ne ${${KEYMAP/vicmd/"\e[2 q"}/(main|viins)/"\e[6 q"}
	PS1=$'\n%F{red}%n@%m%f %F{blue}%~%f %F{red}%(?..%?)%f\n${${KEYMAP/vicmd/"%F{magenta}"}/(main|viins)/}>%f '
	PS2=$'${${KEYMAP/vicmd/"%F{magenta}"}/(main|viins)/}>%f '
	zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Text objects
if bindkey -M viopp &>/dev/null && bindkey -M visual &>/dev/null; then
	autoload -Uz select-bracketed select-quoted
	zle -N select-bracketed
	zle -N select-quoted
	for km in viopp visual; do
		for c in {a,i}${(s..)^:-"()[]{}<>bB"}; bindkey -M $km $c select-bracketed
		for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; bindkey -M $km $c select-quoted
	done
fi

# Command line editor
autoload -z edit-command-line
zle -N edit-command-line

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for km in vicmd viins; do
	for c in "^p" "^[OA" "^[[A"; bindkey -M $km $c up-line-or-beginning-search
	for c in "^n" "^[OB" "^[[B"; bindkey -M $km $c down-line-or-beginning-search
done

# Completion
[[ -d $ZSH_DATA/plugins/arzsh-complete ]] && fpath=($fpath $ZSH_DATA/plugins/arzsh-complete)
[[ -d $ZSH_DATA/plugins/zsh-completions ]] && fpath=($fpath $ZSH_DATA/plugins/zsh-completions/src)
zmodload zsh/complist
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zcompdump
_comp_options+=(globdots)
zstyle ":completion:*" menu select
zstyle ":completion:*" completer _complete _match _approximate
zstyle ":completion:*" matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "+l:|=* r:|=*"
zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path "$XDG_CACHE_HOME/zcompcache"
zstyle ":completion:*" group-name ""
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*:*:*:*:descriptions" format "%F{green}-- %d --%f"
zstyle ":completion:*:messages" format " %F{purple} -- %d --%f"
zstyle ":completion:*:warnings" format " %F{red}-- no matches found --%f"
bindkey "^[[Z" reverse-menu-complete
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "l" vi-forward-char
bindkey -M menuselect "j" vi-down-line-or-history
bindkey -M menuselect "\e" send-break

# Word delimiters
autoload -U select-word-style
select-word-style bash

# Syntax highlighting
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
	&& source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	|| source $ZSH_DATA/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[default]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=red"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=blue"
ZSH_HIGHLIGHT_STYLES[path]="fg=cyan,underline"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=blue,underline"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=blue,underline"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=green"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=green"
ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[assign]="none"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=yellow,bold"
ZSH_HIGHLIGHT_STYLES[named-fd]="none"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=blue"
