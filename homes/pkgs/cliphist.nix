# clipboard manager
{ ... }: {

  imports = [ ./bemenu.nix ./wl-clipboard.nix ];

  services.cliphist.enable = true;

  wayland.windowManager.sway.config.keybindings."Mod4+v" = "exec cliphist list | bemenu --prompt 'Clipboard' | cliphist decode | wl-copy";

}
