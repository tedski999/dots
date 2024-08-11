# cat but better
{ ... }: {
  programs.bat.enable = true;
  programs.bat.config = { style = "plain"; wrap = "never"; };
  programs.zsh.shellGlobalAliases.cat = "bat --paging=never ";
}
