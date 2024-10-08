{ pkgs, ... }: {

  home.stateVersion = "23.05";
  home.preferXdgDirectories = true;
  home.language = { base = "en_IE.UTF-8"; };
  home.keyboard = { layout = "ie"; options = [ "caps:escape" ]; };
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.packages = [ pkgs.nix ];

  nix.package = pkgs.nix;
  nix.settings.auto-optimise-store = true;
  nix.settings.use-xdg-base-directories = true;
  nix.settings.warn-dirty = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

}
