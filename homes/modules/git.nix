# bitkeeper but better
{ ... }: {
  programs.git.enable = true;
  programs.git.aliases.l = "log";
  programs.git.aliases.s = "status";
  programs.git.aliases.a = "add";
  programs.git.aliases.c = "commit";
  programs.git.aliases.cm = "commit --message";
  programs.git.aliases.ps = "push";
  programs.git.aliases.pl = "pull";
  programs.git.aliases.d = "diff";
  programs.git.aliases.ds = "diff --staged";
  programs.git.aliases.rs = "restore --staged";
  programs.git.aliases.un = "reset --soft HEAD~";
  programs.git.aliases.b = "branch";
  programs.git.delta.enable = true;
  programs.git.delta.options.features = "navigate";
  programs.git.delta.options.relative-paths = true;
  programs.git.delta.options.width = "variable";
  programs.git.delta.options.paging = "always";
  programs.git.delta.options.line-numbers = true;
  programs.git.delta.options.line-numbers-left-format = "";
  programs.git.delta.options.line-numbers-right-format = "{np:>4} ";
  programs.git.delta.options.navigate-regex = "^[-+=!>]";
  programs.git.delta.options.file-added-label = "+";
  programs.git.delta.options.file-copied-label = "=";
  programs.git.delta.options.file-modified-label = "!";
  programs.git.delta.options.file-removed-label = "-";
  programs.git.delta.options.file-renamed-label = ">";
  programs.git.delta.options.file-style = "brightyellow";
  programs.git.delta.options.file-decoration-style = "omit";
  programs.git.delta.options.hunk-label = "#";
  programs.git.delta.options.hunk-header-style = "file line-number";
  programs.git.delta.options.hunk-header-file-style = "blue";
  programs.git.delta.options.hunk-header-line-number-style = "grey";
  programs.git.delta.options.hunk-header-decoration-style = "omit";
  programs.git.delta.options.blame-palette = "#101010 #282828";
  programs.git.delta.options.blame-separator-format = "{n:^5}";
  # TODO(later)
  #[pull] rebase = false
  #[push] default = current
  #[merge] conflictstyle = diff3
  #[diff] colorMoved = default
}
