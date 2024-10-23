# grep but better
{ ... }: {

  programs.ripgrep.enable = true;
  programs.ripgrep.arguments = [
    "--follow"
    "--hidden"
    "--smart-case"
    "--max-columns=512"
    "--max-columns-preview"
    "--glob=!{**/node_modules/*,**/.git/*,**/RPMS/*,**/SRPMS/*}"
    "--type-add=tac:*.tac"
    "--type-add=tac:*.tac"
    "--type-add=tin:*.tin"
    "--type-add=itin:*.itin"
  ];

}
