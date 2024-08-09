# python2 but better
{ pkgs, config, ... }: {
  home.packages = with pkgs; [ python3 ];
}
