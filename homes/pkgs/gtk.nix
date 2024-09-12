# gtk config
{ pkgs, ... }: {

  gtk.enable = true;
  gtk.theme = { package = pkgs.materia-theme; name = "Materia-dark"; };
  gtk.iconTheme = { package = pkgs.kdePackages.breeze-icons; name = "breeze-dark"; };
  #gtk.cursorTheme = { package = pkgs.; name = ""; };

}
