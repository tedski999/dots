# fonts
{ pkgs, ... }: {

  home.packages = with pkgs; [ terminus-nerdfont ];

  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Terminess Nerd Font" ];
  fonts.fontconfig.defaultFonts.sansSerif = [];
  fonts.fontconfig.defaultFonts.serif = [];
  fonts.fontconfig.defaultFonts.emoji = [];

}
