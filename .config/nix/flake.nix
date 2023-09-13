# TODO: nixify patched mosh install
# opt mosh "https://github.com/mobile-shell/mosh/archive/refs/tags/mosh-1.4.0.tar.gz"
# dl "https://github.com/mobile-shell/mosh/pull/1167.diff"
# patch -p1 -i "$dl" -d "$out/mosh-mosh-1.4.0"
# cd "$out/mosh-mosh-1.4.0" && ./autogen.sh && ./configure && make

{
  inputs.enable_gui.url = "github:boolean-option/false";
  inputs.nixgl.url = "github:guibou/nixGL";
  outputs = { self, nixpkgs, enable_gui, nixgl }:
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
            # gui and cli packages
            zsh
            zsh-syntax-highlighting
            zsh-autosuggestions
            zsh-completions
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
            # TODO: lots of common utils like mandb
          ] ++ (if enable_gui.value then [
            # gui only packages
            hyprland
            pkgs.nixgl.auto.nixGLDefault
            dbus
            seatd
            terminus_font_ttf
            alacritty
            brave
          ] else [
            # cli only packages
          ]);
          extraOutputsToInstall = [ "man" "doc" ];
        };
      });
    };
}
