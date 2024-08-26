# gtk config
{ pkgs, ... }: {
  gtk.enable = true;
  #gtk.gtk2.extraConfig = ''gtk-key-theme-name = "Emacs"'';
  #gtk.gtk3.extraConfig.gtk-key-theme-name = "Emacs";
  #gtk.gtk4.extraConfig.gtk-key-theme-name = "Emacs";
  gtk.theme = { package = pkgs.materia-theme; name = "Materia-dark"; };
  gtk.iconTheme = { package = pkgs.kdePackages.breeze-icons; name = "breeze-dark"; };
  #gtk.cursorTheme = { package = pkgs.; name = ""; };
}
