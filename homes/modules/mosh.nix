# mosh but better
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (mosh.overrideAttrs (final: prev: {
      #patches = prev.patches ++ [ ./mosh_cursorstyles.diff ];
    }))
  ];
}
