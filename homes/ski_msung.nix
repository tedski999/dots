{ pkgs, ... }: {
  home.username = "ski";
  home.homeDirectory = "/home/ski";
  systemd.user.startServices = "sd-switch";

  imports = [
    ./features/devtools
    ./features/syncthing
  ];
}
