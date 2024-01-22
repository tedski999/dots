{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  # inputs.nixgl.url = "github:guibou/nixGL";
  outputs = { self, nixpkgs }:
   let
     systems = [ "x86_64-linux" "aarch64-linux" ];
     forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn (
       import nixpkgs {
         system = "${sys}";
         # overlays = [ nixgl.overlay ];
         # config.allowUnfree = true;
       }
     ));
   in {
     packages = forAllSystems (pkgs: {
       default = pkgs.buildEnv {
         name = "dots";
         paths = with pkgs; [
          zsh
          zsh-autosuggestions
          zsh-completions
          neovim
          ripgrep
          fzf
          bat
          fd
          eza
          delta
          btop
          git
          lf
          # curl wget tar gzip zip unzip gnupg man-db man-pages jq bc
        ];
        # extraOutputsToInstall = [ "man" "doc" ];
       };
     });
   };
}
