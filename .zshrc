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
alias di="dots init"
alias ll="ls -l"
alias la="ll -a"
alias lt="la -T"
alias d="dirs -v"
for i ({1..9}) alias "$i"="cd +$i"
for i ({3..9}) alias "${(l:i::.:)}"="${(l:i-1::.:)};.."
alias sudo='sudo --preserve-env env PATH=$PATH:/sbin:/usr/sbin '
hash ip 2>/dev/null && alias ip="ip --color"
hash eza 2>/dev/null && alias ls="eza -hs=name --group-directories-first"
hash bat 2>/dev/null && alias cat="bat --paging=never" && alias less="bat --paging=always"
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
zle-line-init() { echo -ne "\e[6 q" }

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for k in "^[p" "^[OA" "^[[A"; bindkey "$k" up-line-or-beginning-search
for k in "^[n" "^[OB" "^[[B"; bindkey "$k" down-line-or-beginning-search

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
export LESS_TERMCAP_mb="$(tput setaf 2; tput blink)"
export LESS_TERMCAP_md="$(tput setaf 0; tput bold)"
export LESS_TERMCAP_me="$(tput sgr0)"
export LESS_TERMCAP_so="$(tput setaf 3; tput smul; tput bold)"
export LESS_TERMCAP_se="$(tput sgr0)"
export LESS_TERMCAP_us="$(tput setaf 4; tput smul)"
export LESS_TERMCAP_ue="$(tput sgr0)"
export LESS="--ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT --RAW-CONTROL-CHARS --lesskey-file=$XDG_CONFIG_HOME/less/key"
command less --help | grep -q -- --incsearch && export LESS="--incsearch $LESS"

# Arista Shell
export ARZSH_COMP_UNSAFE=1
ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new ${@:+-c -- a4c shell $@} }
_ash() { compadd "$(ssh us260 -- a4c ps -N)" }
compdef _ash ash

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

# GPG+SSH
hash gpgconf 2>/dev/null && {
	export GPG_TTY="$(tty)"
	export SSH_AGENT_PID=""
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	(gpgconf --launch gpg-agent &)
}

# cht.sh
cht() { cht.sh "$@?style=paraiso-dark" }
_cht() { compadd $commands:t }
compdef _cht cht

# FZF
export FZF_COLORS="fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red"
export FZF_BINDINGS="ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview"
export FZF_DEFAULT_OPTS="--multi --bind=$FZF_BINDINGS --preview-window sharp --marker=k --color=$FZF_COLORS --history $XDG_DATA_HOME/fzf_history"
export FZF_DEFAULT_COMMAND="rg --files --no-messages"
export FZF_CTRL_T_COMMAND="fd --hidden --exclude '.git' --exclude 'node_modules'"
export FZF_ALT_C_COMMAND="fd --hidden --exclude '.git' --exclude 'node_modules' --type d"
source "$XDG_STATE_HOME/nix/profile/share/fzf/key-bindings.zsh"
source "$XDG_STATE_HOME/nix/profile/share/fzf/completion.zsh"

# Autosuggestions
source "$XDG_STATE_HOME/nix/profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting
source "$XDG_STATE_HOME/nix/profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
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

# Start desktop environment
[[ -o interactive && -o login && -z "$DISPLAY" && "$(tty)" = "/dev/tty1" ]] && hash river 2>/dev/null && {
	exec nixGL river 2>/dev/null
}

:
