# fuzzy finder
{ config, ... }: {

  programs.fzf.enable = true;
  programs.fzf.colors = { "fg" = "bold"; "pointer" = "red"; "hl" = "red"; "hl+" = "red"; "gutter" = "-1"; "marker" = "red"; };
  programs.fzf.changeDirWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules' --type d";
  programs.fzf.fileWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules'";
  programs.fzf.defaultCommand = "rg --files --no-messages";
  programs.fzf.defaultOptions = [
    "--multi"
    "--bind='ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview'"
    "--preview-window sharp"
    "--marker=k"
    "--color=fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red"
    "--history ${config.xdg.dataHome}/fzf_history"
  ];

}
