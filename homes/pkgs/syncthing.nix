{ config, ... }: {

  services.syncthing.enable = true;
  services.syncthing.extraOptions = [
    "--data=${config.xdg.dataHome}/syncthing"
    "--config=${config.xdg.configHome}/syncthing"
    "--no-default-folder"
  ];

}
