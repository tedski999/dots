# screen but better
{ ... }: {
  programs.tmux.enable = true;
  # TODO(tmux): reconfigure minimal tmux
  programs.tmux.baseIndex = 1;
  programs.tmux.escapeTime = 10;
  programs.tmux.historyLimit = 50000;
  programs.tmux.keyMode = "vi";
  programs.tmux.mouse = true;
  programs.tmux.terminal = "screen-256color";
  # TODO(later): migrate config
  programs.tmux.extraConfig = ''
    set -g set-titles on
    set -g set-titles-string "#W"
    set -g focus-events on
    set -g set-clipboard on
    #setw -g mode-style bg=colour8,fg=terminal
    #bind -T copy-mode-vi v send -X begin-selection
    #bind -T copy-mode-vi C-v send -X rectangle-toggle
    #bind -T copy-mode-vi y send -X copy-selection
    #bind -T copy-mode-vi Y send -X copy-end-of-line
    #bind -T copy-mode-vi C-y send -X copy-line
    #set -ga terminal-overrides ",xterm-256color:RGB,xterm-256color:Ms=\\E]52;c;%p2%s\\7"
    # Sessions
    bind S new-session
    # Windows
    #set -g renumber-windows on
    #set -g allow-rename off
    # Panes
    #set -g pane-border-style fg=colour8,dim,overline
    #set -g pane-active-border-style fg=terminal,bold
    # Status
    set -g status off
    set -g status-fg white
    set -g status-bg colour235
    set -g status-position top
    #set -g status-left ' #(a dt ls -au tedj | tail -n +3 | cut -d" " -f1)'
    set -g status-right '#(TZ=Europe/Dublin date "+%%H:%%M IST") | #(TZ=US/Pacific date "+%%H:%%M PDT") | #(TZ=Australia/Sydney date "+%%H:%%M AEST") '
    setw -g window-status-format ""
    setw -g window-status-current-format ""
    bind t set-option status
  '';
}
