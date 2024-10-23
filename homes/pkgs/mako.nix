# dunst but better
{ config, ... }: {

  imports = [ ./bemenu.nix ./fontconfig.nix ./gtk.nix ];

  services.mako.enable = true;
  services.mako.width = 450;
  services.mako.height = 150;
  services.mako.layer = "overlay";
  services.mako.maxVisible = 10;
  services.mako.defaultTimeout = 0;
  services.mako.backgroundColor = "#303030";
  services.mako.borderColor = "#ffffff";
  services.mako.progressColor = "#808080";
  services.mako.font = "Terminess Nerd Font 12";
  services.mako.icons = true;
  services.mako.maxIconSize = 32;
  services.mako.iconPath = "${config.gtk.iconTheme.package}/share/icons/breeze-dark";
  services.mako.extraConfig = ''
    max-history=10
    on-button-left=exec makoctl menu bemenu --prompt "Action"
    on-button-right=dismiss
    [actionable]
    format=<b>%s</b> •\n%b
    [urgency=low]
    background-color=#202020
    text-color=#d0d0d0
    border-color=#808080
    [urgency=high]
    default-timeout=0
    background-color=#c00000
    border-color=#ff0000
    [category=osd]
    format=%s\n%b
    group-by=category
    default-timeout=500
    history=0
  '';

  wayland.windowManager.sway.config.keybindings."Mod4+grave"         = "exec makoctl dismiss";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+grave"   = "exec makoctl restore";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+grave" = "exec makoctl menu bemenu --prompt 'Action'";

}
