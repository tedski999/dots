# fonts
{ pkgs, ... }: {
  home.packages = with pkgs; [ terminus-nerdfont ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [ "Terminess Nerd Font" ];
    sansSerif = [];
    serif = [];
    emoji = [];
  };
}
