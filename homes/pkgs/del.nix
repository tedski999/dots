# rm but better
{ pkgs, ... }: {

  home.packages = with pkgs; [ trashy ];

  programs.zsh.shellAliases.rm = "2>&1 echo rm disabled use del; false ";
  programs.zsh.shellAliases.trash = "trash --table never ";
  programs.zsh.shellAliases.del = "trash put ";
  programs.zsh.shellAliases.undel = "trash restore ";
  programs.zsh.shellAliases.lsdel = "trash list ";
  programs.zsh.shellAliases.deldel = "trash empty ";

}
