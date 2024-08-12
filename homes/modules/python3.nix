# python2 but better
{ pkgs, config, ... }: {
  home.packages = with pkgs; [ python3 ];
  programs.zsh.shellAliases.p = "python3 ";
}
