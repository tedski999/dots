# chrome but better
{ pkgs, ... }: {

  home.sessionVariables.BROWSER = "firefox";
  home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;

  programs.firefox.enable = true;

  wayland.windowManager.sway.config.keybindings."Mod4+w" = "exec firefox";

}
