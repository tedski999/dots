# sed but better
{ pkgs, ... }: {

  home.packages = with pkgs; [ gawk ];

}
