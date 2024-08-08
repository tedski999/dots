# htop but better
{ ... }: {
  programs.btop.enable = true;
  programs.btop.settings = {
    theme_background = false;
    vim_keys = true;
    rounded_corners = false;
    update_ms = 1000;
    proc_sorting = "cpu lazy";
    proc_tree = false;
    proc_filter_kernel = true;
    proc_aggregate = true;
  };
}
