# zsh but worse
{ config, ... }: {

  programs.bash.enable = true;
  programs.bash.historyControl = [ "ignoreboth" ];
  programs.bash.historyFile = "${config.xdg.dataHome}/bash_history";
  programs.bash.initExtra = ''hash zsh 2>/dev/null && [[ $- == *i* ]] && [ -z "$ARTEST_RANDSEED" ] && { shopt -q login_shell && exec zsh --login $@ || exec zsh $@; }'';

}
