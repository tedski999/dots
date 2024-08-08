# zsh but worse
{ config, ... }: {
  programs.bash.enable = true;
  programs.bash.historyControl = [ "ignoreboth" ];
  programs.bash.historyFile = "${config.xdg.dataHome}/bash_history";
  programs.bash.initExtra = "shopt -q login_shell && exec zsh --login $@";
}
