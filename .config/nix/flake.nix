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
            gnupg
            pinentry
            man-db
            lvm2
            openssh
            file
            gnutar
            zip
            unzip
            jq
            wl-clipboard
            python3
          ] ++ (if enable_gui.value then [
            # gui only packages
            river
            pkgs.nixgl.auto.nixGLDefault
            # TODO: fix desktop portal and pipewire
            xdg-desktop-portal
            xdg-desktop-portal-wlr
            pipewire
            wireplumber
            # pulseaudio
            # pulsemixer
            playerctl
            wlr-randr
            light
            terminus_font_ttf
            noto-fonts
            noto-fonts-cjk
            noto-fonts-emoji
            alacritty
            brave
            vieb
            steam # TODO: try out steam-tui
            discord # TODO: try out discordo
            obs-studio
            # TODO: installed natively for now
            # fontconfig
            # fontconfig-config
            # TODO: insecure
            # googleearth-pro
            # TODO: configure systemd user
            # bluez
            # bluez-tools
            # go-mtpfs
            # fuse
            # upower
            # polkit
            # TODO: apply theming
            # paper-icon-theme
            # materia-theme
            # flat-remix-icon-theme
          ] else [
            # cli only packages
          ]);
          extraOutputsToInstall = [ "man" "doc" ];
        };
      });
    };
}
