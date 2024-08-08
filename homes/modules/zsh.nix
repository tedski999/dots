# bash but better
{ config, ... }: {
  programs.zsh.enable = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.defaultKeymap = "emacs";
  programs.zsh.enableCompletion = true;
  programs.zsh.completionInit = "autoload -U compinit && compinit -d '${config.xdg.cacheHome}/zcompdump'";
  programs.zsh.history = { path = "${config.xdg.dataHome}/zsh_history"; extended = true; ignoreAllDups = true; share = true; save = 1000000; size = 1000000; };
  programs.zsh.localVariables.PROMPT = "\n%F{red}%n@%m%f %F{blue}%T %~%f %F{red}%(?..%?)%f\n>%f ";
  programs.zsh.localVariables.TIMEFMT = "\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P";
  programs.zsh.shellAliases.z = "exec zsh ";
  programs.zsh.shellAliases.v = "nvim ";
  programs.zsh.shellAliases.p = "python3 ";
  programs.zsh.shellAliases.c = "cargo ";
  programs.zsh.shellAliases.g = "git ";
  programs.zsh.shellAliases.rm = "2>&1 echo rm disabled, use del; return 1 && ";
  programs.zsh.shellAliases.ls = "eza ";
  programs.zsh.shellAliases.ll = "ls -la ";
  programs.zsh.shellAliases.lt = "ll -T ";
  programs.zsh.shellAliases.ip = "ip --color ";
  programs.zsh.shellAliases.sudo = "sudo --preserve-env ";
  programs.zsh.shellGlobalAliases.cat = "bat --paging=never ";
  programs.zsh.shellGlobalAliases.grep = "rg ";
  programs.zsh.autosuggestion = { enable = true; strategy = [ "history" "completion" ]; };
  programs.zsh.localVariables.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 100;
  programs.zsh.localVariables.ZSH_AUTOSUGGEST_ACCEPT_WIDGETS = [ "end-of-line" "vi-end-of-line" "vi-add-eol" ];
  programs.zsh.localVariables.ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS = [ "forward-char" "vi-forward-char" "forward-word" "emacs-forward-word" "vi-forward-word" "vi-forward-word-end" "vi-forward-blank-word" "vi-forward-blank-word-end" "vi-find-next-char" "vi-find-next-char-skip" ];
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.syntaxHighlighting.styles.default = "fg=cyan";
  programs.zsh.syntaxHighlighting.styles.unknown-token = "fg=red";
  programs.zsh.syntaxHighlighting.styles.reserved-word = "fg=blue";
  programs.zsh.syntaxHighlighting.styles.path = "fg=cyan,underline";
  programs.zsh.syntaxHighlighting.styles.suffix-alias = "fg=blue,underline";
  programs.zsh.syntaxHighlighting.styles.precommand = "fg=blue,underline";
  programs.zsh.syntaxHighlighting.styles.commandseparator = "fg=magenta";
  programs.zsh.syntaxHighlighting.styles.globbing = "fg=magenta";
  programs.zsh.syntaxHighlighting.styles.history-expansion = "fg=magenta";
  programs.zsh.syntaxHighlighting.styles.single-hyphen-option = "fg=green";
  programs.zsh.syntaxHighlighting.styles.double-hyphen-option = "fg=green";
  programs.zsh.syntaxHighlighting.styles.rc-quote = "fg=cyan,bold";
  programs.zsh.syntaxHighlighting.styles.dollar-double-quoted-argument = "fg=cyan,bold";
  programs.zsh.syntaxHighlighting.styles.back-double-quoted-argument = "fg=cyan,bold";
  programs.zsh.syntaxHighlighting.styles.back-dollar-quoted-argument = "fg=cyan,bold";
  programs.zsh.syntaxHighlighting.styles.assign = "none";
  programs.zsh.syntaxHighlighting.styles.redirection = "fg=yellow,bold";
  programs.zsh.syntaxHighlighting.styles.named-fd = "none";
  programs.zsh.syntaxHighlighting.styles.arg0 = "fg=blue";
  programs.zsh.initExtra = ''
    setopt autopushd pushdsilent promptsubst notify completeinword globcomplete globdots
    # word delimiters
    autoload -U select-word-style
    select-word-style bash
    # home end delete
    bindkey "^[[H"  beginning-of-line
    bindkey "^[[F"  end-of-line
    bindkey "^[[3~" delete-char
    # command line editor
    autoload edit-command-line
    zle -N edit-command-line
    bindkey "^V" edit-command-line
    # beam cursor
    zle -N zle-line-init
    zle-line-init() { echo -ne "\e[6 q" }
    # history search
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    for k in "^[p" "^[OA" "^[[A"; bindkey "$k" up-line-or-beginning-search
    for k in "^[n" "^[OB" "^[[B"; bindkey "$k" down-line-or-beginning-search
    # completion
    autoload -U bashcompinit && bashcompinit
    bindkey "^[[Z" reverse-menu-complete
    zstyle ":completion:*" menu select
    zstyle ":completion:*" completer _complete _match _approximate
    zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "+l:|=* r:|=*"
    zstyle ":completion:*" expand prefix suffix 
    zstyle ":completion:*" use-cache on
    zstyle ":completion:*" cache-path "${config.xdg.cacheHome}/zcompcache"
    zstyle ":completion:*" group-name ""
    zstyle ":completion:*" list-colors "''${(s.:.)LS_COLORS}"
    zstyle ":completion:*:*:*:*:descriptions" format "%F{green}-- %d --%f"
    zstyle ":completion:*:messages" format " %F{purple} -- %d --%f"
    zstyle ":completion:*:warnings" format " %F{red}-- no matches --%f"
  '';
}
