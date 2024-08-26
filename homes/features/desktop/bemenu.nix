# gui fuzzy search menu
{ pkgs, config, ... }: {
  programs.bemenu.enable = true;
  programs.bemenu.settings = {
    single-instance = true;
    list = 32;
    center = true;
    fixed-height = true;
    width-factor = 0.5;
    grab = true;
    ignorecase = true;
    border = 1;
    bdr = "#ffffff";
    tb = "#000000";
    tf = "#ffffff";
    fb = "#000000";
    ff = "#ffffff";
    cb = "#ffffff";
    cf = "#ffffff";
    nb = "#000000";
    nf = "#ffffff";
    hb = "#ffffff";
    hf = "#000000";
    fbb = "#ff0000";
    fbf = "#00ff00";
    sb = "#ff0000";
    sf = "#ffffff";
    ab = "#000000";
    af = "#ffffff";
    fn = "Terminess Nerd Font";
  };
}
