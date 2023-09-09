{
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "dots";
        paths = with pkgs; [
          # desktop environment
          bspwm
          sxhkd
          picom #TODO: better picom?
          clipmenu
          rofi
          dmenu
          # applications
          alacritty #TODO: replace alacritty?
          # shell
          zsh
          zsh-autosuggestions
          zsh-completions
          # cli tools
          neovim
          ripgrep
          fzf
          bat
          fd
          eza
          delta
          btop

          #rust
        ];
        # extraOutputsToInstall = [ "man" "doc" ];
        # pathsToLink = [ "/share/man" "/share/doc" "/bin" ];
      };
    };
}
