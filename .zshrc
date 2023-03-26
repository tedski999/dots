# Environment variables
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="less"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export GOPATH="$XDG_DATA_HOME/go"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export npm_config_userconfig="$XDG_CONFIG_HOME/npm/npmrc"
export ZSH_DATA="$XDG_DATA_HOME/zsh"
export MakoProfile="SwitchApp_layer3-mid-latency_48x10G"
export LESS="--ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS"
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

# Prompt
PS1=$'\n%F{red}%n@%m%f %F{blue}%~%f %F{red}%(?..%?)%f\n>%f '

# Better time format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# Aliases
alias sudo="sudo --preserve-env env PATH=$PATH "
alias dots="git --git-dir=$HOME/.local/dots --work-tree=$HOME"
alias v="nvim"
alias r="ranger"
alias p="python3"
alias fd="fdfind"
alias bat="batcat"
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias ip="ip --color=auto"
alias ls="exa -hs=name --group-directories-first"
alias la="ls -la"
alias d="dirs -v"
for i ({1..9}) alias "$i"="cd +$i"
for i ({3..9}) alias "${(l:i::.:)}"="${(l:i-1::.:)};.."
if [ "${HOST%%.*}" != "us260" ]; then
	alias us="2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new"
	alias s="us -A"
	alias S='mut=$(M) && us -c a ssh $mut'
else
	alias s="a4c shell"
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
setopt hist_ignore_all_dups hist_reduce_blanks inc_append_history extended_history
setopt numericglobsort prompt_subst
setopt glob_complete complete_in_word

# Colours
eval "$(dircolors -b)"

# External editor
autoload edit-command-line
zle -N edit-command-line
bindkey "^V" edit-command-line

# Beam cursor
zle -N zle-line-init
function zle-line-init { echo -ne "\e[6 q" }

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for k in "^p" "^[OA" "^[[A"; bindkey $k up-line-or-beginning-search
for k in "^n" "^[OB" "^[[B"; bindkey $k down-line-or-beginning-search

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

# Word delimiters
autoload -U select-word-style
select-word-style bash

# FZF integration
export FZF_DEFAULT_OPTS='--multi --bind=ctrl-j:accept,ctrl-k:toggle --preview-window sharp --marker=k --color=fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red'
export FZF_DEFAULT_COMMAND='rg --files --no-messages'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type=d --color=never --hidden --strip-cwd-prefix'
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] \
	&& source /usr/share/doc/fzf/examples/key-bindings.zsh \
	|| source $ZSH_DATA/plugins/fzf/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] \
	&& source /usr/share/doc/fzf/examples/completion.zsh \
	|| source $ZSH_DATA/plugins/fzf/completion.zsh

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
