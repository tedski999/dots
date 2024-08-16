# arista shell
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "ash" ''
      LC_ALL= mosh \
        --predict=always --predict-overwrite \
        --experimental-remote-ip=remote \
        bus-home -- ~/.local/state/nix/profile/bin/tmux new ''${@:+-c -- a4c shell $@}
    '')
    (writeShellScriptBin "asl" "arista-ssh check-auth || arista-ssh login")
  ];
  programs.zsh.initExtra = ''_ash() { compadd $(ssh bus-home -- a4c ps -N); }; compdef _ash ash'';
}
