# cat but better
{ ... }: {
  programs.bat.enable = true;
  programs.bat.config.style = "plain";
  programs.bat.config.wrap = "never";
  programs.bat.config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
  programs.zsh.shellGlobalAliases.cat = "bat --paging=never ";
}
