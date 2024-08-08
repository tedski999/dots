# cht.sh wrapper
{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    cht-sh
    (writeShellScriptBin "cht" ''cht.sh "$@?style=paraiso-dark"'')
  ];
  programs.zsh.initExtra = "_cht() { compadd $commands:t; }; compdef _cht cht";
}
