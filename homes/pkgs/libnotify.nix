# notification cli client
{ pkgs, ... }: {

  imports = [ ./gtk.nix ];

  home.packages = with pkgs; [ libnotify ];

}
