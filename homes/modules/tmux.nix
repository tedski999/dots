# screen but better
# TODO(work): scrolling
{ ... }: {
  programs.tmux.enable = true;
  programs.tmux.sensibleOnTop = false;
  programs.tmux.prefix = "M-a";
  programs.tmux.baseIndex = 1;
  programs.tmux.escapeTime = 10;
  programs.tmux.historyLimit = 50000;
  #programs.tmux.keyMode = "vi";
  programs.tmux.aggressiveResize = true;
  programs.tmux.terminal = "screen-256color";
  # TODO(later): migrate config
  programs.tmux.extraConfig = ''
    set -g set-titles on
    set -g set-titles-string "#W"
    set -g focus-events on
    #setw -g mode-style bg=colour8,fg=terminal
    #bind -T copy-mode-vi v send -X begin-selection
    #bind -T copy-mode-vi C-v send -X rectangle-toggle
    #bind -T copy-mode-vi y send -X copy-selection
    #bind -T copy-mode-vi Y send -X copy-end-of-line
    #bind -T copy-mode-vi C-y send -X copy-line
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
