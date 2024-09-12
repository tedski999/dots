# found
{ pkgs, ... }: {

  home.packages = with pkgs; [ findutils ];

}
