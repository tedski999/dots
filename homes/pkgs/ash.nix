# arista shell
{ pkgs, ... }: {

  imports = [ ./mosh.nix ];

  home.packages = with pkgs; [
    (writeShellScriptBin "ash" ''
      host="''${1:+tedj-$1}"
      LC_ALL= mosh \
        --predict=always --predict-overwrite --experimental-remote-ip=remote \
        "''${host:-bus-home}" -- ~/.local/state/nix/profile/bin/tmux new
    '')
  ];

  programs.zsh.initExtra = "compdef 'compadd $(cat /tmp/ashcache 2>/dev/null || ssh bus-home -- a4c ps -N | tee /tmp/ashcache)' ash";

}
