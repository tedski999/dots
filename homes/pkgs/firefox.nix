# chrome but better
{ pkgs, ... }: {

  home.sessionVariables.BROWSER = "firefox";
  home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;

  programs.firefox.enable = true;
  programs.firefox.profiles.home = { # TODO(later): firefox sync
    id = 1;
    name = "Home";
    isDefault = true;
    settings = {};
    bookmarks = [];
  };

  wayland.windowManager.sway.config.keybindings."Mod4+w" = "exec firefox";

}
