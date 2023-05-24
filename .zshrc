#!/bin/zsh

PS1=$'\n%F{red}%n@%m%f %F{blue}%~%f %F{red}%(?..%?)%f\n>%f '
HISTSIZE="10000"
SAVEHIST="10000"
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# Options
setopt autocd interactive_comments notify
setopt auto_pushd pushd_ignore_dups pushd_silent
setopt hist_ignore_all_dups hist_reduce_blanks inc_append_history
setopt numericglobsort prompt_subst
setopt glob_complete complete_in_word

# Aliases
alias v="nvim"
alias p="python3"
alias c="cargo"
alias g="git"
alias ll="ls -l"
alias la="ll -a"
alias lt="la -T"
alias d="dirs -v"
for i ({1..9}) alias "$i"="cd +$i"
for i ({3..9}) alias "${(l:i::.:)}"="${(l:i-1::.:)};.."
alias man='man -M "$XDG_DATA_HOME/man:$(manpath -g)"'
alias sudo="sudo --preserve-env env PATH=$PATH "
hash ip 2>/dev/null && alias ip="ip --color"
hash exa 2>/dev/null && alias ls="exa -hs=name --group-directories-first"
hash bat 2>/dev/null && alias cat="bat" && alias less="bat"
hash rg 2>/dev/null && alias grep="rg"
hash delta 2>/dev/null && alias diff="delta"

# Primary keybindings
bindkey -e
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[3~" delete-char

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
for k in "^p" "^[OA" "^[[A"; bindkey "$k" up-line-or-beginning-search
for k in "^n" "^[OB" "^[[B"; bindkey "$k" down-line-or-beginning-search

# Completion
autoload -Uz compinit
fpath=($fpath "$ZSH_DATA/completions")
_comp_options+=(globdots)
compinit -d "$XDG_CACHE_HOME/zcompdump" $([[ -n "$XDG_CACHE_HOME/zcompdump"(#qN.mh+24) ]] && echo -C)
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

# Pager
eval "$(dircolors -b)"
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS="--ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS"
command less --help | grep -q -- --incsearch && export LESS="--incsearch $LESS"

# GPG+SSH
hash gpgconf 2>/dev/null && {
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	(gpgconf --launch gpg-agent &)
}

# Delta
[[ -f "$HOME/.local/opt/delta/completion.zsh" ]] && {
	source "$HOME/.local/opt/delta/completion.zsh"
	export GIT_PAGER="delta"
	export DELTA_FEATURES="+side-by-side"
}

# FZF
export FZF_COLORS="fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red"
export FZF_BINDINGS="ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview"
export FZF_DEFAULT_OPTS="--multi --bind=$FZF_BINDINGS --preview-window sharp --marker=k --color=$FZF_COLORS --history $XDG_DATA_HOME/fzf_history"
export FZF_DEFAULT_COMMAND="rg --files --no-messages"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --type=d --color=never --hidden --strip-cwd-prefix"
[[ -f "$HOME/.local/opt/fzf/key-bindings.zsh" ]] && source "$HOME/.local/opt/fzf/key-bindings.zsh"
[[ -f "$HOME/.local/opt/fzf/completion.zsh" ]] && source "$HOME/.local/opt/fzf/completion.zsh"

# Arista Shell
export ARZSH_COMP_UNSAFE=1
ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new ${@:+-c -- a4c shell $@} }
_ash() { compadd "$(ssh us260 -- a4c ps -N)" }
compdef _ash ash

# Cheatsheets
function cht { curl "cht.sh/$1" }
_cht() { compadd $commands:t }
compdef _cht cht

# File sharing
0x0() { curl -F"file=@$1" https://0x0.st }

# Generic unpacker
un() {
	[[ -z "$1" ]] && echo "Usage: $0 [infile] [outdir]" && return 1
	infile="$1"
	outdir="${2:-.}"
	filetype="$(file -b "$infile")"
	[[ ! -d "$outdir" ]] && mkdir -p "$outdir"
	case "${filetype:l}" in
		"zip archive"*) unzip -d "$outdir" "$infile" ;;
		"gzip compressed"*) tar -xvzf "$infile" -C "$outdir" ;;
		"bzip2 compressed"*) tar -xvjf "$infile" -C "$outdir" ;;
		"posix tar archive"*) tar -xvf "$infile" -C "$outdir" ;;
		"xz compressed data"*) tar -xvJf "$infile" -C "$outdir" ;;
		"rar archive"*) unrar x "$infile" "$outdir" ;;
		"7-zip archive"*) 7z x "$infile" "-o$outdir" ;;
		"cannot open"*) echo "Could not read file: $infile"; return 1 ;;
		*) echo "Unsupported file type: $filetype"; return 1 ;;
	esac
}

# Autosuggestions
[[ -f "$HOME/.local/opt/zsh-autosuggestions/zsh-autosuggestions-0.7.0/zsh-autosuggestions.zsh" ]] && {
	source "$HOME/.local/opt/zsh-autosuggestions/zsh-autosuggestions-0.7.0/zsh-autosuggestions.zsh"
}

# Syntax highlighting
[[ -f "$HOME/.local/opt/zsh-syntax-highlighting/zsh-syntax-highlighting-master/zsh-syntax-highlighting.zsh" ]] && {
	source "$HOME/.local/opt/zsh-syntax-highlighting/zsh-syntax-highlighting-master/zsh-syntax-highlighting.zsh"
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
}
