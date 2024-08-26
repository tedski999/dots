{ pkgs, ... }: {
  home.sessionVariables.QT_QPA_PLATFORM = "wayland";
  home.sessionVariables.LIBSEAT_BACKEND = "logind";
  home.packages = with pkgs; [ nixgl.nixGLIntel libnotify jq wl-clipboard brightnessctl grim slurp pulsemixer ];
  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway --unsupported-gpu'';
  imports = [
    ./alacritty.nix
    ./batteryd.nix
    ./bemenu.nix
    ./bitwarden.nix
    ./cliphist.nix
    ./displayctl.nix
    ./firefox.nix
    ./fontconfig.nix
    ./gtk.nix
    ./imv.nix
    ./mako.nix
    ./mpv.nix
    ./networkctl.nix
    ./playerctl.nix
    ./powerctl.nix
    ./scratch.nix
    ./sway.nix
    ./swaylock.nix
    ./waybar.nix
    ./xdg.nix
  ];
}
