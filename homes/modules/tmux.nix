# screen but better
{ ... }: {
  programs.tmux.enable = true;
  programs.tmux.prefix = "M-a";
  programs.tmux.baseIndex = 1;
  programs.tmux.historyLimit = 100000;
  programs.tmux.extraConfig = ''
    set -g escape-time 250
    set -g repeat-time 250
    set -g status off
    set -g set-clipboard on
    set -g set-titles on
    set -g set-titles-string "#S:#W"

    # i'll take it from here
    unbind -aT prefix
    unbind -aT root
    unbind -aT copy-mode
    unbind -aT copy-mode-vi

    # client
    bind d   detach
    bind r   refresh-client
    bind C-z suspend-client

    # sessions
    bind \$ command-prompt -I "#S" { rename-session "%%" }
    bind s  choose-tree -s

    # copy-mode
    bind a   copy-mode
    bind M-a copy-mode
    bind -T copy-mode r      send-keys -X refresh-from-pane
    bind -T copy-mode y      send-keys -X copy-pipe
    bind -T copy-mode q      if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
    bind -T copy-mode i      if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
    bind -T copy-mode Escape if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
    bind -T copy-mode C-c    if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }

    # copy-mode cursor
    bind -T copy-mode k     send-keys -X cursor-up
    bind -T copy-mode C-p   send-keys -X cursor-up
    bind -T copy-mode j     send-keys -X cursor-down
    bind -T copy-mode C-n   send-keys -X cursor-down
    bind -T copy-mode h     send-keys -X cursor-left
    bind -T copy-mode C-b   send-keys -X cursor-left
    bind -T copy-mode l     send-keys -X cursor-right
    bind -T copy-mode C-f   send-keys -X cursor-right
    bind -T copy-mode ^     send-keys -X back-to-indentation
    bind -T copy-mode 0     send-keys -X start-of-line
    bind -T copy-mode C-a   send-keys -X start-of-line
    bind -T copy-mode Home  send-keys -X start-of-line
    bind -T copy-mode \$    send-keys -X end-of-line
    bind -T copy-mode C-e   send-keys -X end-of-line
    bind -T copy-mode End   send-keys -X end-of-line
    bind -T copy-mode w     send-keys -X next-word
    bind -T copy-mode b     send-keys -X previous-word
    bind -T copy-mode e     send-keys -X next-word-end
    bind -T copy-mode M-b   send-keys -X previous-word
    bind -T copy-mode M-f   send-keys -X next-word-end
    bind -T copy-mode B     send-keys -X previous-space
    bind -T copy-mode E     send-keys -X next-space-end
    bind -T copy-mode W     send-keys -X next-space
    bind -T copy-mode \{    send-keys -X previous-paragraph
    bind -T copy-mode \}    send-keys -X next-paragraph
    bind -T copy-mode H     send-keys -X top-line
    bind -T copy-mode L     send-keys -X bottom-line
    bind -T copy-mode M     send-keys -X middle-line
    bind -T copy-mode G     send-keys -X history-bottom
    bind -T copy-mode g     send-keys -X history-top
    bind -T copy-mode f     command-prompt -1 -p "(jump forward)"  { send-keys -X jump-forward  "%%" }
    bind -T copy-mode F     command-prompt -1 -p "(jump backward)" { send-keys -X jump-backward "%%" }
    bind -T copy-mode t     command-prompt -1 -p "(jump to forward)"  { send-keys -X jump-to-forward  "%%" }
    bind -T copy-mode T     command-prompt -1 -p "(jump to backward)" { send-keys -X jump-to-backward "%%" }
    bind -T copy-mode \;    send-keys -X jump-again
    bind -T copy-mode ,     send-keys -X jump-reverse

    # copy-mode search
    bind -T copy-mode /     command-prompt -T search -p "(search down)" { send-keys -X search-forward "%%" }
    bind -T copy-mode ?     command-prompt -T search -p "(search up)" { send-keys -X search-backward "%%" }
    bind -T copy-mode :     command-prompt -p "(goto line)" { send-keys -X goto-line "%%" }
    bind -T copy-mode *     send-keys -FX search-forward  "#{copy_cursor_word}"
    bind -T copy-mode \#    send-keys -FX search-backward "#{copy_cursor_word}"
    bind -T copy-mode \%    send-keys -X next-matching-bracket
    bind -T copy-mode n     send-keys -X search-again
    bind -T copy-mode N     send-keys -X search-reverse

    # copy-mode scroll
    bind -T root      PPage   copy-mode \; send-keys -X page-up
    bind -T root      Up      copy-mode \; send-keys -X -N 2 scroll-up
    bind -T copy-mode C-b     send-keys -X page-up
    bind -T copy-mode PPage   send-keys -X page-up
    bind -T copy-mode C-f     send-keys -X page-down
    bind -T copy-mode NPage   send-keys -X page-down
    bind -T copy-mode C-u     send-keys -X halfpage-up
    bind -T copy-mode C-d     send-keys -X halfpage-down
    bind -T copy-mode C-y     send-keys -X scroll-up
    bind -T copy-mode C-e     send-keys -X scroll-down
    bind -T copy-mode z       send-keys -X scroll-middle
    bind -T copy-mode Up      send-keys -X -N 2 scroll-up
    bind -T copy-mode Down    send-keys -X -N 2 scroll-down
    bind -T copy-mode Left    send-keys -X -N 2 scroll-left
    bind -T copy-mode Right   send-keys -X -N 2 scroll-right

    # copy-mode selection
    bind -T copy-mode v                send-keys -X begin-selection
    bind -T copy-mode V                send-keys -X select-line
    bind -T copy-mode C-v              if-shell -F "#{selection_present}" { send-keys -X rectangle-toggle } { send-keys -X begin-selection; if-shell -F "#{rectangle_toggle}" {} { send-keys -X rectangle-toggle } }
    bind -T copy-mode o                send-keys -X other-end

    # copy-mode repeats
    bind -T copy-mode 1                 command-prompt -N -I 1 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 2                 command-prompt -N -I 2 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 3                 command-prompt -N -I 3 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 4                 command-prompt -N -I 4 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 5                 command-prompt -N -I 5 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 6                 command-prompt -N -I 6 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 7                 command-prompt -N -I 7 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 8                 command-prompt -N -I 8 -p (repeat) { send-keys -N "%%" }
    bind -T copy-mode 9                 command-prompt -N -I 9 -p (repeat) { send-keys -N "%%" }
  '';
}
