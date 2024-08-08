# screen but better
{ ... }: {
  programs.tmux.enable = true;
  # TODO(tmux): reconfigure minimal tmux
  # TODO(later): migrate config
  programs.tmux.extraConfig = ''
    set -g mouse on
    set -g focus-events on
    set -g set-clipboard on
    set -s escape-time 10
    set -g history-limit 50000
    # Copying
    setw -g mode-keys vi
    setw -g mode-style bg=colour8,fg=terminal
    bind -T copy-mode-vi v send -X begin-selection
    bind -T copy-mode-vi C-v send -X rectangle-toggle
    bind -T copy-mode-vi y send -X copy-selection
    bind -T copy-mode-vi Y send -X copy-end-of-line
    bind -T copy-mode-vi C-y send -X copy-line
    # Terminal
    set -g set-titles on
    set -g set-titles-string "#W"
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ",xterm-256color:RGB,xterm-256color:Ms=\\E]52;c;%p2%s\\7"
    # Sessions
    bind S new-session
    # Windows
    set -g base-index 1
    set -g renumber-windows on
    set -g allow-rename off
    # Panes
    setw -g pane-base-index 1
    set -g pane-border-style fg=colour8,dim,overline
    set -g pane-active-border-style fg=terminal,bold
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
