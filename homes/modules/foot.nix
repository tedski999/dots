{ ... }: {
  home.sessionVariables.TERMINAL = "foot";
  programs.foot.enable = true;
  programs.foot.server.enable = true;
  programs.foot.settings = {
    main.term = "xterm-256color";
    main.font = "Terminess Nerd Font:size=13.5";
    main.font-size-adjustment = 1.5;
    main.initial-window-size-pixels = "1600x900";
    main.pad = "0x0 center";
    scrollback.lines = 100000;
    colors.alpha = 0.85;
    colors.flash = "ffffff";
    colors.background = "000000";
    colors.foreground = "dddddd";
    colors.regular0 = "000000";
    colors.regular1 = "cc0403";
    colors.regular2 = "19cb00";
    colors.regular3 = "cecb00";
    colors.regular4 = "0d73cc";
    colors.regular5 = "cb1ed1";
    colors.regular6 = "0dcdcd";
    colors.regular7 = "dddddd";
    colors.bright0  = "767676";
    colors.bright1  = "f2201f";
    colors.bright2  = "23fd00";
    colors.bright3  = "fffd00";
    colors.bright4  = "1a8fff";
    colors.bright5  = "fd28ff";
    colors.bright6  = "14ffff";
    colors.bright7  = "ffffff";
    colors.selection-foreground = "000000";
    colors.selection-background = "fffacd";
    colors.scrollback-indicator = "000000 fffacd";
    key-bindings.spawn-terminal = "Control+Shift+Return";
    key-bindings.prompt-prev = "Control+Shift+p";
    key-bindings.prompt-next = "Control+Shift+n";
    key-bindings.pipe-command-output = "[wl-copy] Control+Shift+x";
    key-bindings.scrollback-up-line = "Page_Up";
    key-bindings.scrollback-up-half-page = "Shift+Page_Up";
    key-bindings.scrollback-up-page = "Control+Page_Up";
    key-bindings.scrollback-home = "Control+Shift+Page_Up";
    key-bindings.scrollback-down-line = "Page_Down";
    key-bindings.scrollback-down-half-page = "Shift+Page_Down";
    key-bindings.scrollback-down-page = "Control+Page_Down";
    key-bindings.scrollback-end = "Control+Shift+Page_Down";
    key-bindings.search-start = "Control+Shift+Escape";
    search-bindings.find-prev = "Control+p";
    search-bindings.find-next = "Control+n";
    search-bindings.delete-prev = "BackSpace";
    search-bindings.delete-prev-word = "Control+w Control+BackSpace";
    search-bindings.delete-next = "Control+d Delete";
    search-bindings.delete-next-word = "Mod1+d Control+Delete";
    search-bindings.extend-char = "Control+l Shift+Right";
    search-bindings.extend-to-word-boundary = "Control+Shift+Right";
    search-bindings.extend-line-down = "Control+j Shift+Down";
    search-bindings.extend-backward-char = "Control+h Shift+Left";
    search-bindings.extend-backward-to-word-boundary = "Control+Shift+Left";
    search-bindings.extend-line-up = "Control+k Shift+Up";
    search-bindings.scrollback-up-line = "Page_Up";
    search-bindings.scrollback-up-half-page = "Shift+Page_Up";
    search-bindings.scrollback-up-page = "Control+Page_Up";
    search-bindings.scrollback-home = "Control+Shift+Page_Up";
    search-bindings.scrollback-down-line = "Page_Down";
    search-bindings.scrollback-down-half-page = "Shift+Page_Down";
    search-bindings.scrollback-down-page = "Control+Page_Down";
    search-bindings.scrollback-end = "Control+Shift+Page_Down";
  };
  programs.zsh.initExtra = ''
    function precmd { print -Pn "\e]133;A\e\\"; if ! builtin zle; then print -n "\e]133;D\e\\"; fi; }
    function preexec { print -n "\e]133;C\e\\"; }
    function osc7-pwd() {
        (( ZSH_SUBSHELL )) && return
        emulate -L zsh
        setopt extendedglob
        local LC_ALL=C
        printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
    }
    add-zsh-hook -Uz chpwd osc7-pwd
  '';
}
