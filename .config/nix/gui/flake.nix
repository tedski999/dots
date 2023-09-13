{
  inputs.nixgl.url = "github:guibou/nixGL";
  outputs = { self, nixpkgs, nixgl }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn (
        import nixpkgs {
          system = "${sys}";
          overlays = [ nixgl.overlay ];
          config.allowUnfree = true;
        }
      ));
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
          name = "dots";
          paths = with pkgs; [

            # desktop environment
            hyprland
            pkgs.nixgl.auto.nixGLDefault
            dbus
            seatd
            terminus_font_ttf

            # applications
            alacritty
            brave

          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
      });
    };
}
