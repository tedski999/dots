# whats the diff anyway
{ pkgs, ... }: {

  home.packages = with pkgs; [ diffutils ];

}
