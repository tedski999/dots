# pkill pid
{ pkgs, ... }: {

  home.packages = with pkgs; [ procps ];

}
