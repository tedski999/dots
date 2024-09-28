# gui fuzzy search menu
{ ... }: {

  imports = [ ./fontconfig.nix ];

  home.sessionVariables.LAUNCHER = "bemenu-run";

  programs.bemenu.enable = true;
  programs.bemenu.settings.single-instance = true;
  programs.bemenu.settings.list = 32;
  programs.bemenu.settings.center = true;
  programs.bemenu.settings.fixed-height = true;
  programs.bemenu.settings.width-factor = 0.5;
  programs.bemenu.settings.grab = true;
  programs.bemenu.settings.ignorecase = true;
  programs.bemenu.settings.border = 1;
  programs.bemenu.settings.bdr = "#ffffff";
  programs.bemenu.settings.tb = "#000000";
  programs.bemenu.settings.tf = "#ffffff";
  programs.bemenu.settings.fb = "#000000";
  programs.bemenu.settings.ff = "#ffffff";
  programs.bemenu.settings.cb = "#ffffff";
  programs.bemenu.settings.cf = "#ffffff";
  programs.bemenu.settings.nb = "#000000";
  programs.bemenu.settings.nf = "#ffffff";
  programs.bemenu.settings.hb = "#ffffff";
  programs.bemenu.settings.hf = "#000000";
  programs.bemenu.settings.fbb = "#ff0000";
  programs.bemenu.settings.fbf = "#00ff00";
  programs.bemenu.settings.sb = "#ff0000";
  programs.bemenu.settings.sf = "#ffffff";
  programs.bemenu.settings.ab = "#000000";
  programs.bemenu.settings.af = "#ffffff";
  programs.bemenu.settings.fn = "Terminess Nerd Font";

}
