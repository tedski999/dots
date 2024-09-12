# cht.sh wrapper
{ pkgs, ... }: {

  home.packages = with pkgs; [
    cht-sh
    (writeShellScriptBin "cht" ''cht.sh "$@?style=paraiso-dark"'')
  ];

  programs.zsh.initExtra = "compdef 'compadd $commands:t' cht";

}
