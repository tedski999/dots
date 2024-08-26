# ls but better
{ ... }: {
  programs.eza.enable = true;
  programs.eza.extraOptions = [ "--header" "--sort=name" "--group-directories-first" ];
  programs.eza.git = true;
  programs.zsh.shellAliases.ls = "eza ";
  programs.zsh.shellAliases.ll = "ls -la ";
  programs.zsh.shellAliases.lt = "ll -T ";
}
