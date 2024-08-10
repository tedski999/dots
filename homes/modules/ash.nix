# arista shell
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "ash" ''
      arista-ssh check-auth || arista-ssh login && mosh \
        --predict=always --predict-overwrite \
        --experimental-remote-ip=remote \
        bus-home ''${@:+-- a4c shell $@}
    '')
  ];
  programs.zsh.initExtra = ''_ash() { compadd "$(ssh bus-home -- a4c ps -N)"; }; compdef _ash ash'';
}
