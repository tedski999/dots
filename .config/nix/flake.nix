{
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
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
            zsh-syntax-highlighting
            zsh-autosuggestions
            zsh-completions
            # cli tools
            git
            neovim
            ripgrep
            fzf
            bat
            fd
            eza
            delta
            btop
            cht-sh
            #rust
          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
      });
    };
}
