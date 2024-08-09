# arista mosh
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (mosh.overrideAttrs (final: prev: { patches = prev.patches ++ [ ./mosh.patch ]; }))
    (writeShellScriptBin "ash" ''
      # TODO(tmux): ash+tmux+a4c-shell
      #ash() { eval 2>/dev/null mosh --predict=always --predict-overwrite --experimental-remote-ip=remote bus-home -- tmux new ''${@:+-c -- a4c shell $@}; }
      arista-ssh check-auth || arista login && LC_ALL= mosh \
        --predict=always \
        --predict-overwrite \
        --experimental-remote-ip=remote \
        bus-home -- tmux new ''${@:+-c -- a4c shell $@}
    '')
  ];
  programs.zsh.initExtra = ''_ash() { compadd "$(ssh bus-home -- a4c ps -N)"; }; compdef _ash ash'';
}
