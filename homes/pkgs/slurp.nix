# select region
{ pkgs, ... }: {

  home.packages = with pkgs; [ slurp ];

}
