{ pkgs, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  imports = [
    ./features/devtools
    ./features/desktop
    ./features/syncthing
  ];

  # arista vpn+shelllogin+shell
  home.packages = with pkgs; [
    mosh
    openconnect
    (writeShellScriptBin "avpn" ''
      sudo openconnect \
        --protocol=gp gp-ie.arista.com \
        -u tedj \
        -c $HOME/Documents/keys/tedj@arista.com.crt \
        -k $HOME/Documents/keys/tedj@arista.com.pem
    '')
    (writeShellScriptBin "asl" ''
      arista-ssh check-auth || arista-ssh login
    '')
    (writeShellScriptBin "ash" ''
      LC_ALL= mosh \
        --predict=always --predict-overwrite \
        --experimental-remote-ip=remote \
        bus-home -- ~/.local/state/nix/profile/bin/tmux new ''${@:+-c -- a4c shell $@}
    '')
  ];
  programs.zsh.initExtra = "compdef 'compadd $(ssh bus-home -- a4c ps -N)' ash";

  # install homebus ssh configuration
  programs.ssh.matchBlocks."bus-home".host = "bus-home";
  programs.ssh.matchBlocks."bus-home".hostname = "10.247.176.6";
  programs.ssh.matchBlocks."bus-home".port = 22251;
  programs.ssh.matchBlocks."bus".host = "bus-*";
  programs.ssh.matchBlocks."bus".user = "tedj";
  programs.ssh.matchBlocks."bus".forwardAgent = true;
  programs.ssh.matchBlocks."bus".extraOptions = {
    StrictHostKeyChecking = "false";
    UserKnownHostsFile = "/dev/null";
    RemoteForward = "/bus/gnupg/S.gpg-agent \${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra";
  };
}
