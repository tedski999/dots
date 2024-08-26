# TODO(now): conflict between installer nix and home-manager nix
# TODO(next): disable nvidia (investigate random crashes)
# TODO(next): ragenix: gpg key, ssh keys (homebus->gitar and personal), bitwarden login, firefox sync, syncthing keys, arista keys
# TODO(later): obs-studio
# TODO(later): beets
# TODO(nixos): live+instal iso
{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; }; # TODO(nixos): nixpkgs-* vs nixos-*
    home-manager = { url = "github:nix-community/home-manager/master"; inputs = { nixpkgs.follows = "nixpkgs"; }; };
    nixgl = { url = "github:nix-community/nixGL"; inputs = { nixpkgs.follows = "nixpkgs"; }; };
    nur = { url = "github:nix-community/NUR"; };
  };

  outputs = { nur, nixgl, ...  } @ inputs:
  let
    pkgs = inputs.nixpkgs.legacyPackages;
    lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
  in {
    devShells = lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: {
      default = with pkgs.${system}; mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes\nuse-xdg-base-directories = true";
        buildInputs = [ nix home-manager git ];
      };
    });
    nixosConfigurations = {
      "msung" = lib.nixosSystem { modules = [ ./hosts/common.nix ./hosts/msung.nix ]; };
      "septs" = lib.nixosSystem { modules = [ ./hosts/common.nix ./hosts/septs.nix ]; };
    };
    homeConfigurations = {
      "ski@msung" = lib.homeManagerConfiguration { modules = [ ./homes/common.nix ./homes/ski_msung.nix ]; pkgs = (pkgs.x86_64-linux.extend nur.overlay).extend nixgl.overlay; };
      "ski@septs" = lib.homeManagerConfiguration { modules = [ ./homes/common.nix ./homes/ski_septs.nix ]; pkgs = pkgs.aarch64-linux; };
      "tedj@work" = lib.homeManagerConfiguration { modules = [ ./homes/common.nix ./homes/tedj_work.nix ]; pkgs = (pkgs.x86_64-linux.extend nur.overlay).extend nixgl.overlay; };
      "tedj@wbus" = lib.homeManagerConfiguration { modules = [ ./homes/common.nix ./homes/tedj_wbus.nix ]; pkgs = pkgs.x86_64-linux; };
    };
  };
}
