# screen but better
{ ... }: {
  programs.tmux.enable = true;
  programs.tmux.prefix = "M-a";
  programs.tmux.escapeTime = 10;
  programs.tmux.extraConfig = ''
    set -g status off
    set -g status-fg white
    set -g status-bg colour235
    set -g status-position top
    set -g pane-border-style fg=colour8,dim,overline
    set -g pane-active-border-style fg=terminal,bold
    setw -g window-status-format ""
    setw -g window-status-current-format ""
    setw -g mode-style bg=colour8,fg=terminal
    bind S new-session
    bind t set-option status
  '';
}
