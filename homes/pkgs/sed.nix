# awk but better
{ pkgs, ... }: {

  home.packages = with pkgs; [ gnused ];

}
