# slock but better
{ pkgs, config, ... }: {
  programs.swaylock.enable = true;
  programs.swaylock.package = pkgs.runCommandWith { name = "swaylock-dummy"; } "mkdir $out"; # NOTE: slock must be installed on system for PAM integration
  programs.swaylock.settings = {
    ignore-empty-password = true;
    image = "eDP-1:${config.xdg.configHome}/swaylock/swaylock.png";
    scaling = "center";
    color = "000000";
    indicator-radius = 25;
    indicator-thickness = 8;
    indicator-y-position = 600;
    key-hl-color = "ffffff";
    bs-hl-color = "000000";
    separator-color = "000000";
    inside-color = "00000000";
    inside-clear-color = "00000000";
    inside-caps-lock-color = "00000000";
    inside-wrong-color = "00000000";
    inside-ver-color = "00000000";
    line-color = "000000";
    line-clear-color = "000000";
    line-caps-lock-color = "000000";
    line-wrong-color = "000000";
    line-ver-color = "000000";
    ring-color = "000000";
    ring-clear-color = "ffffff";
    ring-caps-lock-color = "000000";
    ring-ver-color = "ffffff";
    ring-wrong-color = "000000";
    text-color = "00000000";
    text-clear-color = "00000000";
    text-caps-lock-color = "00000000";
    text-ver-color = "00000000";
    text-wrong-color = "00000000";
  };
  xdg.configFile."swaylock/swaylock.png".source = ./swaylock.png;
}
