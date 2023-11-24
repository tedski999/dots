#!/bin/zsh

# Options
export PROMPT=$'\n%F{red}%n@%m%f %F{blue}%T %~%f %F{red}%(?..%?)%f\n>%f '
export HISTSIZE="1000000"
export SAVEHIST="$HISTSIZE"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'
setopt autocd interactive_comments notify
setopt auto_pushd pushd_ignore_dups pushd_silent
setopt extended_history inc_append_history hist_ignore_space
setopt hist_expire_dups_first hist_ignore_all_dups hist_reduce_blanks
setopt numericglobsort prompt_subst
setopt complete_in_word glob_complete

# opt resources directory
opt="$HOME/.local/share/opt"
[ -d "$opt" ] || mkdir -p "$opt"

# Aliases
alias v="vim"
alias p="python3"
alias c="cargo"
alias g="git"
alias ll="ls -l"
alias la="ll -a"
alias lt="la -T"
alias d="dirs -v"
alias di="dots init $(uname --node)"
alias sudo="sudo --preserve-env "
alias ip="ip --color"
alias ls="eza -hs=name --group-directories-first"
alias cat="bat --paging=never"
alias less="bat --paging=always"
alias grep="rg"
alias z="exec zsh"
hash nvim 2>/dev/null && alias v="nvim"
for i ({1..9}) alias "$i"="cd +$i"
for i ({3..9}) alias "${(l:i::.:)}"="${(l:i-1::.:)};.."

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
zmodload zsh/complist
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zcompdump" $([[ -n "$XDG_CACHE_HOME/zcompdump"(#qN.mh+24) ]] && echo -C)
_comp_options+=(globdots)
autoload -U bashcompinit && bashcompinit
zstyle ":completion:*" menu select
zstyle ":completion:*" complete-options true
zstyle ":completion:*" completer _complete _match _approximate
zstyle ":completion:*" matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "+l:|=* r:|=*"
zstyle ":completion:*" list-suffixes
zstyle ":completion:*" expand prefix suffix 
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

# GPG+SSH
hash gpgconf 2>/dev/null && {
	export GPG_TTY="$(tty)"
	export SSH_AGENT_PID=""
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	(gpgconf --launch gpg-agent &)
}

# Arista Shell
export ARZSH_COMP_UNSAFE=1
ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new ${@:+-c -- a4c shell $@} }
_ash() { compadd "$(ssh us260 -- a4c ps -N)" }
compdef _ash ash

# File sharing
0x0() { curl -F"file=@$1" https://0x0.st }

# cht.sh
[ -f "$opt/cht.sh" ] || { curl -L "https://cht.sh/:cht.sh" > "$opt/cht.sh" || exit 1; }
cht() { bash "$opt/cht.sh" "$@?style=paraiso-dark" | less }
_cht() { compadd $commands:t }
compdef _cht cht

# del
alias rm="2>&1 echo rm disabled, use del; return 1 #"

# delta
diff() { command diff -u $@ | delta }

# lf
lf() {
	f="$XDG_CACHE_HOME/lfcd"
	command lf -last-dir-path "$f" $@
	[ -f "$f" ] && { cd "$(cat $f)"; command rm -f "$f"; }
}

# fd
hash fdfind 2>/dev/null && { fd() { fdfind $@ } }

# fzf
export FZF_COLORS="fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red"
export FZF_BINDINGS="ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview"
export FZF_DEFAULT_OPTS="--multi --bind=$FZF_BINDINGS --preview-window sharp --marker=k --color=$FZF_COLORS --history $XDG_DATA_HOME/fzf_history"
export FZF_DEFAULT_COMMAND="rg --files --no-messages"
export FZF_CTRL_T_COMMAND="fd --hidden --exclude '.git' --exclude 'node_modules'"
export FZF_ALT_C_COMMAND="fd --hidden --exclude '.git' --exclude 'node_modules' --type d"
[ -f "$opt/fzf-key-bindings.zsh" ] || { curl -L "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh" > "$opt/fzf-key-bindings.zsh" || exit 1; }
[ -f "$opt/fzf-completion.zsh" ] || { curl -L "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh" > "$opt/fzf-completion.zsh" || exit 1; }
source "$opt/fzf-key-bindings.zsh"
source "$opt/fzf-completion.zsh"

# Autosuggestions
[ -f "$opt/zsh-autosuggestions-master/zsh-autosuggestions.zsh" ] || { curl -L "https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.tar.gz" | tar -xzC "$opt" || exit 1; }
source "$opt/zsh-autosuggestions-master/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-char vi-forward-char)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100

# Syntax highlighting
[ -f "$opt/zsh-syntax-highlighting-master/zsh-syntax-highlighting.zsh" ] || { curl -L "https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.tar.gz" | tar -xzC "$opt" || exit 1; }
source "$opt/zsh-syntax-highlighting-master/zsh-syntax-highlighting.zsh"
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
[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && hash sway 2>/dev/null && {
	export MOZ_ENABLE_WAYLAND=1
	export SDL_VIDEODRIVER=wayland
	export _JAVA_AWT_WM_NONREPARENTING=1
	export QT_QPA_PLATFORM=wayland
	export QT_STYLE_OVERRIDE=kvantum
	XDG_CURRENT_DESKTOP=sway sway
}

:
