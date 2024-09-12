# ssh but udp
{ pkgs, ... }: {

  home.packages = with pkgs; [ mosh ];

}
