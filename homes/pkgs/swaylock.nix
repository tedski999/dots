# slock but better
{ config, ... }: {

  programs.swaylock.enable = true;
  programs.swaylock.settings.ignore-empty-password = true;
  programs.swaylock.settings.image = "eDP-1:${config.xdg.configHome}/swaylock/swaylock.png";
  programs.swaylock.settings.scaling = "center";
  programs.swaylock.settings.color = "000000";
  programs.swaylock.settings.indicator-radius = 25;
  programs.swaylock.settings.indicator-thickness = 8;
  programs.swaylock.settings.indicator-y-position = 600;
  programs.swaylock.settings.key-hl-color = "ffffff";
  programs.swaylock.settings.bs-hl-color = "000000";
  programs.swaylock.settings.separator-color = "000000";
  programs.swaylock.settings.inside-color = "00000000";
  programs.swaylock.settings.inside-clear-color = "00000000";
  programs.swaylock.settings.inside-caps-lock-color = "00000000";
  programs.swaylock.settings.inside-wrong-color = "00000000";
  programs.swaylock.settings.inside-ver-color = "00000000";
  programs.swaylock.settings.line-color = "000000";
  programs.swaylock.settings.line-clear-color = "000000";
  programs.swaylock.settings.line-caps-lock-color = "000000";
  programs.swaylock.settings.line-wrong-color = "000000";
  programs.swaylock.settings.line-ver-color = "000000";
  programs.swaylock.settings.ring-color = "000000";
  programs.swaylock.settings.ring-clear-color = "ffffff";
  programs.swaylock.settings.ring-caps-lock-color = "000000";
  programs.swaylock.settings.ring-ver-color = "ffffff";
  programs.swaylock.settings.ring-wrong-color = "000000";
  programs.swaylock.settings.text-color = "00000000";
  programs.swaylock.settings.text-clear-color = "00000000";
  programs.swaylock.settings.text-caps-lock-color = "00000000";
  programs.swaylock.settings.text-ver-color = "00000000";
  programs.swaylock.settings.text-wrong-color = "00000000";

  # TODO: embed file
  xdg.configFile."swaylock/swaylock.png".source = ./swaylock.png;

}
