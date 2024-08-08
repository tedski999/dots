# ls but better
{ ... }: {
  programs.eza.enable = true;
  programs.eza.extraOptions = [ "--header" "--sort=name" "--group-directories-first" ];
  programs.eza.git = true;
}
