# mosh but better
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (mosh.overrideAttrs (final: prev: {
      patches = prev.patches ++ [
         #./mosh_cursorstyle.patch
         #./mosh_osc52.patch
        ];
    }))
  ];
}
